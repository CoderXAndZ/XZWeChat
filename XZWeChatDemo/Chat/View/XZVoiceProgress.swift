//
//  XZVoiceProgress.swift
//  XZWeChatDemo
//
//  Created by admin on 2018/8/13.
//  Copyright © 2018年 XZ. All rights reserved.
//

import UIKit

enum XZVoiceRecordState {
    case normal // 初始状态
    case recording // 正在录音
    case releaseToCancel // 上滑取消（也在录音状态，UI显示有区别）
    case recordCounting // 最后10s倒计时（也在录音状态，UI显示有区别）
    case recordTooShort // 录音时间太短（录音结束了）
}

class XZVoiceProgress: UIView {
    
    // 设置音量
    var progress: CGFloat = 0 {
        didSet {
            progress = min(max(progress, 0.0), 1.0)
            
            if voiceRecordState == XZVoiceRecordState.recording {
                setupAnimationImages()
                
                imageView.isHidden = true
                imageAnimationView.isHidden = false
            }
        }
    }
    
    var time: String?
    
    var voiceRecordState:XZVoiceRecordState {
        didSet{
            
            if voiceRecordState == XZVoiceRecordState.recording { // 正在录音
                imageAnimationView.isHidden = true
                imageView.isHidden = false
                imageView.image = UIImage.init(named: "voice_1")
                
                labelTip.text = "手指上移，取消发送"
                labelTip.backgroundColor = UIColor.clear
                labelTime.isHidden = true
            }else if voiceRecordState == XZVoiceRecordState.releaseToCancel { // 取消发送
                
                imageAnimationView.isHidden = true
                imageView.isHidden = false
                imageView.image = UIImage.init(named: "cancelVoice")
                
                labelTip.text = "松开手指，取消发送"
                labelTip.backgroundColor = UIColor(redC: 222, greenC: 130, blueC: 136)
                labelTime.isHidden = true
                
            }else if voiceRecordState == XZVoiceRecordState.recordCounting { // 倒计时
                
                labelTime.isHidden = false
                imageView.isHidden = true
                imageAnimationView.isHidden = true
                
                labelTip.text = "手指上移，取消发送"
                labelTip.backgroundColor = UIColor.clear
                
                labelTime.text = time ?? ""
            }else if voiceRecordState == XZVoiceRecordState.recordTooShort { // 时间太短
                
                imageAnimationView.isHidden = true
                imageView.isHidden = false
                imageView.image = UIImage.init(named: "voiceShort")
                
                labelTime.isHidden = true
                
                labelTip.text = "说话时间太短"
                labelTip.backgroundColor = UIColor.clear
            }
        }
    }
    
    // 设置是否隐藏
    var hiddenProgress: Bool = false {
        didSet {
            for subview  in subviews {
                if hiddenProgress { // 隐藏
                    subview.isHidden = true
                }else { // 显示
                    subview.isHidden = false
                }
            }
            
            time = nil
            progress = 0
        }
    }
    
    override init(frame: CGRect) {
        
        self.voiceRecordState = .normal
        
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// 显示静态图片
    private var imageView = UIImageView()
    /// 显示动画
    private var imageAnimationView = UIImageView()
    /// 动画图片数据
    private var images: NSArray = [
        UIImage.init(named: "voice_1")!,
        UIImage.init(named: "voice_2")!,
        UIImage.init(named: "voice_3")!,
        UIImage.init(named: "voice_4")!,
        UIImage.init(named: "voice_5")!,
        UIImage.init(named: "voice_6")!]
    /// 提示
    private var labelTip = UILabel()
    /// 时间倒计时
    private var labelTime = UILabel()
}

// 设置页面
extension XZVoiceProgress {
    // 设置动画
    func setupAnimationImages() {
        if progress == 0 {
            imageAnimationView.animationImages = []
            imageAnimationView.stopAnimating()
            return
        }
        
        if progress >= 0.8 {
            imageAnimationView.animationImages = [images[3] as! UIImage,images[4] as! UIImage,images[5] as! UIImage,images[4] as! UIImage,images[3] as! UIImage]
        }else if progress >= 0.7 {
             imageAnimationView.animationImages = [images[0] as! UIImage,images[1] as! UIImage,images[2] as! UIImage]
        }else {
            imageAnimationView.animationImages = [images[0] as! UIImage]
        }
        
        imageAnimationView.startAnimating()
    }
    
    // 设置页面
    func setupVoiceProgress() {
        let bgView = UIView()
        addSubview(bgView)
        bgView.snp.makeConstraints { (make) in
            make.edges.equalTo(self)
        }
        bgView.backgroundColor = UIColor.black
        bgView.alpha = 0.5
        
        // 静态图片
        addSubview(imageView)
        imageView.snp.makeConstraints { (make) in
            make.centerX.equalTo(self)
            make.centerY.equalTo(self)
        }
        imageView.image = UIImage.init(named: "voice_1")
        
        // 动画视图
        addSubview(imageAnimationView)
        imageAnimationView.snp.makeConstraints { (make) in
            make.centerX.equalTo(self)
            make.centerY.equalTo(self)
        }
        imageAnimationView.animationDuration = 0.5
        imageAnimationView.animationRepeatCount = -1
        imageAnimationView.isHidden = true
        
        addSubview(labelTime)
        labelTime.snp.makeConstraints { (make) in
            make.centerX.equalTo(self)
            make.centerY.equalTo(self)
        }
        labelTime.isHidden = true
        labelTime.textColor = UIColor.white
        labelTime.font = UIFont.systemFont(ofSize: 50)
        
        addSubview(labelTip)
        labelTip.snp.makeConstraints { (make) in
            make.bottom.equalTo(self).offset(-15)
            make.centerX.equalTo(self)
        }
        labelTip.text = "松开手指，取消发送"
        labelTip.backgroundColor = UIColor.clear
        labelTip.font = UIFont.systemFont(ofSize: 13)
        labelTip.textColor = UIColor.white
    }
    
}

