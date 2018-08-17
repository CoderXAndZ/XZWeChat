//
//  XZVoicePlayer.swift
//  XZWeChatDemo
//
//  Created by admin on 2018/8/13.
//  Copyright © 2018年 XZ. All rights reserved.
//  声音播放

import UIKit
import AVFoundation
import TSVoiceConverter

class XZVoicePlayer: NSObject {
    /// 单例
    static let sharedPlayer = XZVoicePlayer()
    private override init() {} // 阻止其他对象使用这个类的默认的'()'初始化方法
    
    /// 通过地址播放，回调进度
    func playWithURLString(path:String, progress:@escaping(_ value: CGFloat)->()) {
        
        progressValue = progress
        guard var currentPath = currentPath else {
            return
        }
        
        // 当点击了别的行，如果当前正在播放，取消当前行的播放
        // 不能使用当前路径判断，因为再次点击相同行的话，是同一个地址；
        if currentPath != path {
            stop()
            player = nil
            currentPath = path
        }else {
            if isPlaying() {
                stop()
                player = nil
                currentPath = ""
            }
        }
        
        let array = path.components(separatedBy: "/")
        let pathName = array.last
        guard let path = pathName else {
            return
        }
        let voicePath = XZFileTools.recoderPathWithFileName(fileName: path)
        
        let noExtensionPath = (voicePath as NSString).deletingPathExtension
        let wavPath = (noExtensionPath as NSString).appendingPathExtension("wav")
        
        guard let finalPath = wavPath  else {
            return
        }
        
        // 播放本地音频
        if XZFileTools.fileExistsAtPath(path: voicePath) || XZFileTools.fileExistsAtPath(path: finalPath) {
            if voicePath.contains("amr") {
                // amr 转换成 wav
                if TSVoiceConverter.convertAmrToWav(path, wavSavePath: finalPath) { // 转化成功
                    // 移除 .amr 文件
                  _ = XZFileTools.removeFileAtPath(path: path)
                }
            }
            
            let url = URL.init(string: finalPath)
            guard let playUrl = url else {
                return
            }
            // 播放
            playWithURL(url: playUrl)
        }else { // 先下载到本地
            let downloadPath = "https://60.208.74.58:8343/ptm-manage/ptmcall/ptmCdr/downloadRecord/187834/7854/9AE206D76D45108E1EB8219E846C65BC"
            
            XZDownloadManager.downloadAudioWithURL(urlStr: downloadPath, completion: { (url, progressValue, amrPath) in
                if progressValue == 1 {
                    let wavPath = amrPath.replacingOccurrences(of: "amr", with: "wav")
                    
                    if amrPath.contains("amr") {
                        // amr 转换成 wav
                        if TSVoiceConverter.convertAmrToWav(amrPath, wavSavePath: wavPath) {
                            // 移除 .amr 文件
                            _ = XZFileTools.removeFileAtPath(path: path)
                        }
                    }
                    
                    let url = URL.init(string: finalPath)
                    guard let playUrl = url else {
                        return
                    }
                    // 播放
                    self.playWithURL(url: playUrl)
                }
            })
            
        }
    }
    
    func playWithURL(url: URL) {
        DispatchQueue.main.async {
            let session = AVAudioSession.sharedInstance()
            
//            do {
            // 增加音量
            try? session.setCategory(AVAudioSessionCategoryPlayback)
            self.player = try? AVAudioPlayer.init(contentsOf: url)
//            } catch {
//                print("创建播放器失败")
//            }
            // 设置属性
            self.player?.numberOfLoops = 0 // 不循环
            self.player?.delegate = self
            self.player?.isMeteringEnabled = true // 更新音频测量
            // 加载音频文件到缓存
            self.player?.prepareToPlay()
            
            // 播放
            self.play()
        }
    }
    
    /// 播放
    func play() {
        if isPlaying() == false {
            player?.play()
        }
    }
    
    /// 暂停
    func pause() {
        if isPlaying() {
            player?.pause()
        }
    }
    
    /// 停止播放
    func stop() {
        if isPlaying() {
            player?.stop()
            
            player?.delegate = nil
            player = nil
        }
    }
    
    /// 正在播放
    func isPlaying() -> Bool {
        guard let player = player else {
            return false
        }
        return player.isPlaying
    }
    
    // 播放进度回调
    private var progressValue:((_ value: CGFloat)->())?
    private var player: AVAudioPlayer?
    private var currentPath: String?
}

extension XZVoicePlayer: AVAudioPlayerDelegate {
    /// 播放结束时执行的动作
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        
        progressValue?(1)
        stop()
    }
    
    // 被来电打断,停止播放
    func audioPlayerBeginInterruption(_ player: AVAudioPlayer) {
        pause()
    }
    
    // 被来电结束，继续播放
    func audioPlayerEndInterruption(_ player: AVAudioPlayer, withOptions flags: Int) {
        play()
    }
}
