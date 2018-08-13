//
//  XZMediaModel.swift
//  XZWeChatDemo
//
//  Created by admin on 2018/8/13.
//  Copyright © 2018年 XZ. All rights reserved.
//

import UIKit
import Photos

class XZMediaModel: NSObject {
    /** 媒体类型
     FMFileManangerOSSFileTypeVoice    = 0,    // 声音
     FMFileManangerOSSFileTypeVideo    = 1,    // 视频
     FMFileManangerOSSFileTypeImage    = 2,    // 图片
     FMFileManangerOSSFileTypeFIle     = 3,    // 文件
     FMFileManangerOSSFileTypeOther    = 4     // 其他
     */
    var mediaType:Int = -1
    /** 媒体名字  */
    var mediaName: String?
    /** 媒体路径 */
    var mediaPath: String?
    /** 媒体照片 */
    var image: UIImage?
    /** 媒体后缀 png、wav、MP4... */
    var extensionName: String?
    /** 媒体照片大小 */
    var imageSize: CGSize?
    
    /** 视频/声音 时长 */
    var mediaDuration: TimeInterval = 0
    /** 视频的NSData数据 */
    var mediaData: Data?
    /** 视频的第一帧图片 */
    var firstImage: UIImage?
    /** 视频的第一帧图片的data数据 */
    var dataOfFirstImg: NSData?
    /** iOS8 之后的媒体属性 */
    var asset: PHAsset?
    /** 文件大小 */
    var mediaSize: String?
    /** 是否被选中 */
    var isSelected: Bool = false
    
}
