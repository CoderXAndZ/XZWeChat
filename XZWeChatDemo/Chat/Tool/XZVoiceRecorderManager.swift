//
//  XZVoiceRecorderManager.swift
//  XZWeChatDemo
//
//  Created by admin on 2018/8/13.
//  Copyright © 2018年 XZ. All rights reserved.
//  声音录制

import UIKit
import AVFoundation

@objc protocol XZVoiceRecorderManagerDelegate: NSObjectProtocol {
    /// 录制被中断，录制过程中来电话
    func audioRecorderInterrupted(tips: String)
}

class XZVoiceRecorderManager: NSObject {
    
    weak var delegate: XZVoiceRecorderManagerDelegate?
    
    /// 单例
    static let sharedManager = XZVoiceRecorderManager()
    private override init() {} // 阻止其他对象使用这个类的默认的'()'初始化方法
    
    /** 是否需要取消录音 */
    var isNeedCancelRecording = false
    
    private var audioRecorder:AVAudioRecorder?
    private var recorderFinish:((_ recordPath: String)->())?
    /// 录音文件当前存储路径
    private var currentPath: String?
}

extension XZVoiceRecorderManager {
    /// 开始录音
    func startRecordWithFileName(fileName: String,completion:@escaping ()->()) {
        
        isNeedCancelRecording = false
        currentPath = fileName
        
        if canRecord() {
            // 取消当前录制
            if (audioRecorder != nil && (audioRecorder?.isRecording)!) {
                audioRecorder?.stop()
                cancelCurrentRecording()
                return
            }
            
            // 设置策略
            let session = AVAudioSession.sharedInstance()
            try? session.setCategory(AVAudioSessionCategoryPlayAndRecord)
            
            let filePath = XZFileTools.recoderPathWithFileName(fileName: fileName)
            print("录音文件路径",filePath)
            let url = URL(fileURLWithPath: filePath)
            // 录音设备的设置需要跟VoiceConverter一样 [self getAudioSetting]
            let settings = getAudioSetting()
            // 初始化录音设备
            audioRecorder = try? AVAudioRecorder.init(url: url, settings: settings)
            audioRecorder?.delegate = self
            audioRecorder?.isMeteringEnabled = true
            
            if audioRecorder == nil {
                return
            }
            audioRecorder?.prepareToRecord()
            // 开始录音
            audioRecorder?.record()
            
            completion()
        }else {  /// 不允许使用麦克风
            let alertView = UIAlertView(title: "无法访问您的麦克风" , message: "请在iPhone的“设置-隐私-麦克风”选项中，允许访问你的手机麦克风。", delegate: nil, cancelButtonTitle: "取消", otherButtonTitles: "好的")
            alertView.show()
        }
        
    }
    
    /// 停止录制
    func stopRecordingWithCompletion(completion:@escaping (_ recordPath: String)->()) {
        if audioRecorder != nil && (audioRecorder?.isRecording)! {
            audioRecorder?.stop()
            
            recorderFinish = completion
            
            print("回调音频")
        }else {
            print("不是正在录制？？？？")
        }
    }
    
    /// 取消当前录制
    func cancelCurrentRecording() {
        audioRecorder?.stop()
        audioRecorder?.deleteRecording()
        audioRecorder?.delegate = nil
        audioRecorder = nil
        recorderFinish = nil
    }
    
    /// 声音改变获取
    func powerChanged() -> CGFloat {
        
        guard let audioRecorder = audioRecorder else{
            print("声音改变获取: audioRecorder为空")
            return 0.0
        }
        
        audioRecorder.updateMeters()
        // 获取第一通道的音频，范围(-160 ~ 0),声音越大，power值越小
        let power = CGFloat(audioRecorder.averagePower(forChannel: 0))
        let progress = (1.0 / 160.0) * (power + 160)
        print("声音改变获取: ",progress)
        return progress
    }
    
    /// 录音文件设置
    func getAudioSetting() -> [String: Any] {
        var dict = [String: Any]()
        // 设置录音格式
        dict[AVFormatIDKey] = kAudioFormatLinearPCM
        // 设置录音采样率，8000是电话采样率，录音足以
        dict[AVSampleRateKey] = 8000
        // 设置通道：单声道
        dict[AVNumberOfChannelsKey] = 1
        // 每个采样点位数，分为8、16、24、32
        dict[AVLinearPCMBitDepthKey] = 16
        // 是否使用浮点数采样
        dict[AVLinearPCMIsFloatKey] = true
        return dict
    }
    
    /// 访问录音权限
    func canRecord() -> Bool {
        
        var canRecorder = false
        // 判读是否是系统 8.0 以后
        if #available(iOS 8.0, *) {
            let session = AVAudioSession.sharedInstance()
            session.requestRecordPermission({ (granted) in
              canRecorder = granted
            })
        }
        return canRecorder
    }
}

extension XZVoiceRecorderManager: AVAudioRecorderDelegate {
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        print("录音完成!")
        
        if flag == false {
            return
        }
        
        guard let audioRecorder = audioRecorder else {
            return
        }
        
        let recordPath = (audioRecorder.url.path as NSString).deletingPathExtension
        
        // 音频格式转换
        let amrPath = (recordPath as NSString).appendingPathExtension(XZCommon.xz_amrType)
        // ====== wav 转化成 amr
//        [VoiceConverter ConvertWavToAmr:recordPath amrSavePath:amrPath];
        
        guard let amrPathFinal = amrPath else {
            return
        }
        
        recorderFinish?(amrPathFinal)
        
        // 取消时，删除当前录制
        if isNeedCancelRecording == true {
            audioRecorder.deleteRecording()
        }
        
        self.audioRecorder?.delegate = nil
        self.audioRecorder = nil
        
        recorderFinish = nil
        //    // 移除.wav原文件 ============= 删除
        //    [self removeCurrentRecordFile:self.currentFileName];
    }
    
    // 录制过程中造成录音中断
    func audioRecorderBeginInterruption(_ recorder: AVAudioRecorder) {
        // 取消录制，回调控制器
        cancelCurrentRecording()
        
        delegate?.audioRecorderInterrupted(tips: "来电话了")
        print("录制过程中造成录音中断")
    }
    
    func audioRecorderEndInterruption(_ recorder: AVAudioRecorder, withOptions flags: Int) {
        
    }
}

// MARK: - 文件操作
extension XZVoiceRecorderManager {
    /// 根据路径移除文件
    func removeCurrentRecordFile(fileName: String) {
        let path = XZFileTools.recoderPathWithFileName(fileName: fileName)
        if XZFileTools.fileExistsAtPath(path: path) {
           _ = XZFileTools.removeFileAtPath(path: path)
        }
    }
    
    /// 移除当前录制文件
    func removeCurrentRecordFile() {
        removeCurrentRecordFile(fileName: currentFileName())
    }
    
    /// 当前文件名
    func currentFileName() -> String {
        guard let currentPath = currentPath else {
            return ""
        }
        return currentPath.replacingOccurrences(of: "wav", with: "amr")
    }
    
}

//    /// 单例
//    class var sharedManager: XZVoiceRecorderManager {
//        struct Static {
//            static let instance = XZVoiceRecorderManager()
//        }
//        return Static.instance
//    }

//    private let sharedManager = XZVoiceRecorderManager()
//    class XZVoiceRecorderManager {
//        class var sharedManager:XZVoiceRecorderManager {
//            return sharedManager
//        }
//    }
