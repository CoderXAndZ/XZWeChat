//
//  XZFileTools.swift
//  XZWeChatDemo
//
//  Created by admin on 2018/8/13.
//  Copyright © 2018年 XZ. All rights reserved.
//  文件相关工具

import UIKit
import AVFoundation

class XZFileTools {
    
    /// 缓存路径
    class func getAppCacheDirectory() -> String {
        guard let cachesDirectory = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).last else {
            return ""
        }
        
        let process = ProcessInfo.processInfo.processName
        let path = (cachesDirectory as NSString).appendingPathComponent(process)
        
        if FileManager.default.fileExists(atPath: path) == false {
           try? FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
        }
        return path
    }
    
    /// 当前录音的时间作为文件名使用
    class func currentRecordFileName() -> String {
        let uuid = generateUUID()
        
        return  "\(uuid).wav"
    }
    
    /// 生成 UUID
    class func generateUUID() -> String {
        return UUID.init().uuidString
    }
    
    /// 获取语音时长
    class func durationWithVoiceURL(voiceURL: URL) -> TimeInterval {
        let opt = [AVURLAssetPreferPreciseDurationAndTimingKey:false]
        // 初始化媒体文件
        let audioAsset = AVURLAsset.init(url: voiceURL, options: opt)
        let audioDuration = audioAsset.duration
        // 获取总时长，单位秒
        let second = CMTimeGetSeconds(audioDuration)
        return second
    }
    
    /// 根据路径获取文件
    class func getAllDocumentFromFile() -> Array<Any> {
        let manager = FileManager.default
        guard let array =  try? manager.contentsOfDirectory(atPath: mainPathOfDocuments()) else {
            return []
        }
        var documents = [XZMediaModel]()
        
        for path in array {
            if path != ".DS_Store" {
                let filePath = documentPathWithName(name: path)
                
                let model = XZMediaModel()
                model.mediaType = 3
                model.mediaName = path
                model.mediaSize = fileSize(path: filePath)
                model.mediaPath = filePath
                model.extensionName = getTheSuffix(fileName: path)
                
                documents.append(model)
            }
        }
        return documents
    }
    
    /// 录音文件路径
    class func recoderPathWithFileName(fileName: String) -> String {
        let mainPath = mainPathOfDocuments() as NSString
        let path = mainPath.appendingPathComponent(fileName)
        return path
    }
    
    /// 录音文件主路径
    class func mainPathOfRecorder() -> String {
        let path = (getAppCacheDirectory() as NSString).appendingPathComponent(XZCommon.xz_recorderPath)
        
        let manager = FileManager.default
        
        if manager.fileExists(atPath: path) {
           try? manager.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
            return ""
        }
        return path
    }
    
    /// 获取后缀
    class func getTheSuffix(fileName: String) -> String {
        let array = fileName.components(separatedBy: ".")
        let suffix = array.last
        
        return suffix ?? ""
    }
    
    /// 判断文件是否存在
    class func fileExistsAtPath(path: String) -> Bool {
        return FileManager.default.fileExists(atPath: path)
    }
    
    /// 移除 path 路径下的文件
    class func removeFileAtPath(path: String) -> Bool {
        return ((try? FileManager.default.removeItem(atPath: path)) != nil)
    }
    
    /// 某个路径下的文件大小字符串值 小于1024显示KB，否则显示MB
    class func fileSize(path: String) -> String {
        let size = fileSizeWithPath(path: path)
        
        if size > 1024 {
            return String.init(format: "%.1fMB", size / 1024.0)
        }else {
            return String.init(format: "%.1fKB", size)
        }
    }
    
    ///  返回字节 == 文件大小的字节值
    class func fileSizeWithPath(path: String) -> CGFloat {
        if fileExistsAtPath(path: path) {
            guard let fileAttributes =  try? FileManager.default.attributesOfItem(atPath: path) else {
                return 0.0
            }
            return CGFloat((fileAttributes as NSDictionary).fileSize())
        }
        return 0.0
    }
    
    /// 文件路径
    class func documentPathWithName(name: String) -> String {
        let docPath = mainPathOfDocuments()
        let documentPath = (docPath as NSString).appendingPathComponent(name)
        
        return documentPath
    }
    
    /// 文件夹路径
    class func mainPathOfDocuments() -> String {
        
        let path = getAppCacheDirectory() + XZCommon.xz_documentPath
        
        let manager = FileManager.default
        
        if manager.fileExists(atPath: path) == false {
            try? manager.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
            return ""
        }
        return path
    }
}
