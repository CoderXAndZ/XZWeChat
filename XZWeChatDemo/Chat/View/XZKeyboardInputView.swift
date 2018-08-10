//
//  XZKeyboardInputView.swift
//  XZWeChatDemo
//
//  Created by admin on 2018/8/8.
//  Copyright © 2018年 XZ. All rights reserved.
//

import UIKit

@objc protocol XZKeyboardInputViewDelegate: NSObjectProtocol {
    func keyboardInputViewDidSelectedBtn(btnTag: Int)
}

class XZKeyboardInputView: UIView {
    
    weak var delegate: XZKeyboardInputViewDelegate?
    
    var isRobot: Bool = false {
        didSet {
            if (isRobot) { // 是机器人
                arrButton = [
                    ["title":"留言","image":"toolbar_keyboard_message"],
                    ["title":"评价","image":"toolbar_keyboard_ evaluation"],
                ]
            }else { // 人工
                arrButton = [
                    ["title":"图片","image":"toolbar_keyboard_photo"],
                    ["title":"留言","image":"toolbar_keyboard_message"],
                    ["title":"评价","image":"toolbar_keyboard_ evaluation"],
                    ["title":"附件","image":"toolbar_keyboard_attachment"]
                ]
            }
            
            for i in 0..<arrButton.count {
                let button:XZButton = subviews[i] as! XZButton
                button.isHidden = false
                
                let dict = arrButton[i]
                
                let image:String = dict["image"]!
                let title:String = dict["title"]!
                
                button.setImage(UIImage.init(named: image), for: .normal)
                button.setTitle(title, for: .normal)
            }
        }
    }
    
    // 点击按钮
    @objc private func didClickButton(button: XZButton) {
        delegate?.keyboardInputViewDidSelectedBtn(btnTag: button.tag)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupKeyboardInputView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
//    // 点击事件回调
//    public var buttonClickBlock:((_ buttonTag: NSInteger)->())?
    
    // 按钮和图片数据
    private lazy var arrButton:[[String:String]] = []
//    private lazy var arrButton = [Dictionary]()
}

// 设置页面
extension XZKeyboardInputView {
    
    func setupKeyboardInputView() {
        backgroundColor = UIColor.white
        
        let buttonW: CGFloat = (UIScreen.main.bounds.size.width - 30) / 4.0
        for i in 0..<4 {
            let button = XZButton(type: UIButtonType.custom)
            addSubview(button)
            button.xz_buttonType = .PicAbove
            button.isHidden = true
            button.titleLabel?.textColor = UIColor(redC: 51, greenC: 51, blueC: 51)
            button.frame = CGRect(x: 15 + CGFloat(i) * buttonW, y: 20, width: buttonW - 1, height: 60)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 15.0)
            button.tag = 2000 + i
            button.addTarget(self, action: #selector(didClickButton), for: UIControlEvents.touchUpInside)
        }
    }
    
}














