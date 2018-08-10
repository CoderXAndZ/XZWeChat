//
//  XZButton.swift
//  XZWeChatDemo
//
//  Created by admin on 2018/8/8.
//  Copyright © 2018年 XZ. All rights reserved.
//

import UIKit

enum XZButtonType {
    case PicAbove
    case PicRight
    case PicTitleDistance
}

class XZButton: UIButton {
    
    var xz_buttonType: XZButtonType = .PicAbove
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        switch xz_buttonType {
            case .PicAbove: // 图片文字上下布局
                
                // 调整图片的位置和尺寸
                imageView?.frame.origin.y = 0
                imageView?.center.x = frame.size.width * 0.5
                
                // 调整文字的位置和尺寸
                titleLabel?.frame.origin.x = 0
                titleLabel?.frame.origin.y = (imageView?.frame.size.height)!
                titleLabel?.frame.size.width = frame.size.width
                titleLabel?.frame.size.height = frame.size.height - (titleLabel?.frame.origin.y)!
                
                titleLabel?.textAlignment = .center
                break
            case .PicRight: // 文字在左边，图片在右边
                
                // 设置 titleLabel 的 x 位置
                titleLabel?.frame.origin.x = 6
                // 设置 imageView 的 x
                imageView?.frame.origin.x = (titleLabel?.frame.maxX)! + 5
                break
            case .PicTitleDistance: // 图片和文字是左右的，中间有一段距离
                
                titleLabel?.frame.origin.x = (imageView?.frame.maxX)! + 10
                break
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
