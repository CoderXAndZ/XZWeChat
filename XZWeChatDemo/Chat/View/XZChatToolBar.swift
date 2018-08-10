//
//  XZChatToolBar.swift
//  XZWeChatDemo
//
//  Created by admin on 2018/8/8.
//  Copyright © 2018年 XZ. All rights reserved.
//

import UIKit
import SnapKit

@objc protocol XZChatToolBarDelegate: NSObjectProtocol {
    func chatToolBarDidSelectedBtn(btnTag: Int)
}

class XZChatToolBar: UIView {
    
    weak var delegate: XZChatToolBarDelegate?
    
    /// 开启时间计时器
    @objc func timerReduceOneSecond() {
        
    }
    
    /// 点击’转人工‘
    @objc func didClickVoiceButton(button: UIButton) {
        switch button.tag {
            case 120: // 语音/聊天
                button.isSelected = !button.isSelected
                
                if button.isSelected == true { // 语音
                    textView.resignFirstResponder()
                    textView.isHidden = true
                    btnSpeak.isHidden = false
                    
                    // 隐藏”发送“按钮
                    if btnSendMsg.isHidden == false {
                        btnSendMsg.isHidden = true
                        btnContactAdd.isHidden = false
                    }
                }else { // 聊天
                    textView.isHidden = false
                    btnSpeak.isHidden = true
                    textView.becomeFirstResponder()
                    
                    if textView.text.count != 0 {
                        btnSendMsg.isHidden = false
                        btnContactAdd.isHidden = true
                    }
                }
                
                // 隐藏底部视图
                makeKeyboardInputViewConstraints(hidden: false)
                break
            case 121: // 转人工
                btnTurnArtifical.isHidden = true
                btnVoice.isHidden = false
                keyboardInputView.isRobot = false
                
                // =====
                
                break
            case 122: // + 按钮
                button.isSelected = !button.isSelected
                
                textView.resignFirstResponder()
                // 显示输入框
                if textView.isHidden == true {
                    textView.isHidden = false
                    btnSpeak.isHidden = true
                    btnVoice.isSelected = false
                }
                
                makeKeyboardInputViewConstraints(hidden: button.isSelected ? true : false)
                break
            case 123: // ’发送‘按钮
                // ===== 回调
                
                // 清空输入框
                textView.text = ""
//                textUserInput = ""
                // 发送通知
                NotificationCenter.default.post(name: NSNotification.Name.UITextViewTextDidChange, object: textView)
                break
            default:
                break
        }
    }
    
    /// 开始录音
    @objc func speakerTouchDown() {
        
    }
    
    /// 结束录音
    @objc func speakerTouchUpInside() {
        
    }
    
    @objc func speakerTouchUpOutside() {
        
    }
    
    /// 录制过程中拖拽
    @objc func touchDragInsideWithEvent(button:UIButton,event:UIEvent) {
    
    }
    
    /// 接收通知
    @objc func getKeyBoardNotofication() {
        
    }
    
    init(frame: CGRect, barSuperView: UIView) {
        super.init(frame: frame)
        
        self.barSuperView = barSuperView
        /// normal图片
        self.btnSpeakImg = self.btnSpeakImg.xz_resizableImageWithCapInsets(capInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: self.btnSpeakImg.size.width - 1))
        /// hightlighted图片
        self.highlightedImage = self.highlightedImage.xz_resizableImageWithCapInsets(capInsets: UIEdgeInsetsMake(0, 0, 0, self.highlightedImage.size.width - 1))
        
        setupChatToolBar()
        monitorKeyboard()
        
//        addGestureRecognizer(UITapGestureRecognizer(target:self, action:#selector(handleTap(sender:))))
        
    }
    
//    @objc func handleTap(sender: UITapGestureRecognizer) {
//        if sender.state == .ended {
//            textView.resignFirstResponder()
//        }
//        sender.cancelsTouchesInView = false
//    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// 输入框
    private var textView = XZTextView(frame: .zero)
    /// 顶部试图
    private var topView = UIView()
    /// 语音聊天按钮
    private var btnVoice = UIButton(type: .custom)
    /// 按住说话按钮,默认隐藏
    private var btnSpeak = UIButton(type: .custom)
    /// 发送按钮
    private var btnSendMsg = UIButton(type: .custom)
    /// 加号按钮
    private var btnContactAdd = UIButton(type: .custom)
    /// 转人工
    private var btnTurnArtifical = XZButton(type: .custom)
    /// 父视图
    private var barSuperView: UIView!
    /// 当前文字高度
    private var currentTextHeight: CGFloat = 0
    /// normal图片
    private var btnSpeakImg: UIImage = UIImage.init(named: "compose_emotion_table_left_normal")!
    /// highlighted图片
    private var highlightedImage: UIImage = UIImage.init(named: "compose_emotion_table_left_selected")!
    
    /// 60s 倒计时
    private lazy var timerReduce = Timer(timeInterval: minRecordDuration, target: self, selector: #selector(timerReduceOneSecond), userInfo: nil, repeats: true)
    /// 底部 + 视图
    private var keyboardInputView = XZKeyboardInputView(frame: CGRect.zero)

    private let toolBarBtnH: CGFloat = 35.0 // 顶部工具栏按钮和输入框初始高度
    private let toolBarBottom: CGFloat = 100.0 // 底部视图
    private let btnSpeakLeftX: CGFloat = 55.0 // 按住说话左边距
    private let minRecordDuration = 1.0 // 最短录音时间
    private let maxRecordDuration = 60 // 最长录音时间
    private let remainCountingDuration = 10 // 剩余多少秒开始倒计时
}

/// XZKeyboardInputViewDelegate
extension XZChatToolBar: XZKeyboardInputViewDelegate {
    func keyboardInputViewDidSelectedBtn(btnTag: Int) {
        print("选中按钮的tag: ",btnTag)
    }
}

/// 监听键盘通知
extension XZChatToolBar {
    func monitorKeyboard() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillShow), name:NSNotification.Name.UIKeyboardWillShow , object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: Notification.Name.UIKeyboardWillHide, object: nil)
    }
    
    /// 键盘出现或改变时调用
    @objc func keyBoardWillShow(aNotification:Notification) {
        
        guard let userInfo = aNotification.userInfo,
            let aValue = userInfo[UIKeyboardFrameEndUserInfoKey]
        else {
            return
        }
        
        let keyboardRect = (aValue as! NSValue).cgRectValue
        
        let height = keyboardRect.size.height
        
        
        // 隐藏底部视图
        makeKeyboardInputViewConstraints(hidden: false)
        
        print("self?.barSuperView :", barSuperView)
        self.snp.remakeConstraints({[weak self] (make) in
            make.left.right.equalTo((self?.barSuperView)!)
            make.bottom.equalTo((self?.barSuperView)!).offset(-height)
            make.height.equalTo(XZCommon.xz_chatToolBarHeight)
        })
        
//        UIView.animate(withDuration: 0.25) {
//            self.layoutIfNeeded()
//        }
//        }
    }
    
    /// 键盘退出时调用
    @objc func keyboardWillHide(aNotification:Notification) {
        self.snp.remakeConstraints { (make) in
            make.left.bottom.right.equalTo(barSuperView)
            make.height.equalTo(XZCommon.xz_chatToolBarHeight)
        }
        
        // ========
    }
    
    // topView高度
    var toolBar_height:CGFloat {
        return textView.text_height + XZCommon.xz_chatToolBarHeight - toolBarBtnH
    }
    
    func makeKeyboardInputViewConstraints(hidden: Bool) {
        var height = toolBar_height
        
        if textView.isHidden == true {
            height = XZCommon.xz_chatToolBarHeight
        }
        
        if hidden == true { // 显示工具栏底部视图
            topView.snp.remakeConstraints({ (make) in
                make.left.right.equalTo(self)
                make.height.equalTo(height)
                make.bottom.equalTo(self).offset(-toolBarBottom)
            })
            
            keyboardInputView.isHidden = false
            
            keyboardInputView.snp.remakeConstraints({ (make) in
                make.left.right.equalTo(self)
                make.top.equalTo(topView.snp.bottom)
                make.height.equalTo(toolBarBottom)
            })
            
            self.snp.remakeConstraints({ (make) in
                make.left.bottom.right.equalTo(barSuperView)
                make.height.equalTo((height + toolBarBottom))
            })
            
            // ====== 将toolbar的高度传递给控制器，修改tableView
            
        }else { // 隐藏工具栏底部视图
            topView.snp.remakeConstraints({ (make) in
                make.left.right.bottom.equalTo(self)
                make.height.equalTo(height)
            })
            
            keyboardInputView.isHidden = true
            keyboardInputView.snp.updateConstraints({ (make) in
                make.height.equalTo(0)
            })
            
            self.snp.remakeConstraints({ (make) in
                make.left.bottom.right.equalTo(barSuperView)
                make.height.equalTo(height)
            })
            
            // 将加号选中状态还原
            btnContactAdd.isSelected = false
            
            // ===== 将toolbar的高度传递给控制器，修改tableView
        }
    }
}

// 设置页面
extension XZChatToolBar {
    
    func setupChatToolBar() {
        backgroundColor = UIColor.white
        
        let line = UIView()
        addSubview(line)
        line.frame = CGRect(x: 0, y: 0, width: XZCommon.xz_screenWidth, height: 1)
        line.backgroundColor = UIColor(redC: 191, greenC: 191, blueC: 191, isRandom: false)
        
        // 顶部工具栏
        addSubview(topView)
        topView.backgroundColor = UIColor.green
        
        // 底部 + 视图
        addSubview(keyboardInputView)
        keyboardInputView.isRobot = true
        keyboardInputView.backgroundColor = UIColor.orange
        keyboardInputView.delegate = self
        
        // 转人工
        topView.addSubview(btnTurnArtifical)
        btnTurnArtifical.setImage(UIImage.init(named: "toolbar_turnToArtificial"), for: .normal)
        btnTurnArtifical.setTitle("转人工", for: .normal)
        btnTurnArtifical.titleLabel?.font = UIFont.systemFont(ofSize: 12.0)
        btnTurnArtifical.setTitleColor(UIColor(redC: 51, greenC: 51, blueC: 51), for: .normal)
        btnTurnArtifical.tag = 121
        btnTurnArtifical.addTarget(self, action: #selector(didClickVoiceButton), for: .touchUpInside)
        
        /// 语音聊天按钮
        topView.addSubview(btnVoice)
        btnVoice.isHidden = true
        btnVoice.setImage(UIImage.init(named: "toolbar_voice"), for: .normal)
        btnVoice.setImage(UIImage.init(named: "toolbar_input_info"), for: .selected)
        btnVoice.addTarget(self, action: #selector(didClickVoiceButton), for: .touchUpInside)
        btnVoice.tag = 120
        
        /// 按住说话按钮,默认隐藏
        topView.addSubview(btnSpeak)
        btnSpeak.setTitle("按住 说话", for: .normal)
        btnSpeak.setTitleColor(UIColor.black, for: .normal)
        btnSpeak.layer.masksToBounds = true
        btnSpeak.layer.cornerRadius = 15
        btnSpeak.layer.borderWidth = 1.0
        btnSpeak.layer.borderColor = UIColor(redC: 222, greenC: 222, blueC: 222).cgColor
        btnSpeak.titleLabel?.font = UIFont.systemFont(ofSize: 15.0)
        btnSpeak.setBackgroundImage(self.btnSpeakImg, for: .normal)
        // 开始录音
        btnSpeak.addTarget(self, action: #selector(speakerTouchDown), for: .touchDown)
        // 结束录音
        btnSpeak.addTarget(self, action: #selector(speakerTouchUpInside), for: .touchUpInside)
        btnSpeak.addTarget(self, action: #selector(speakerTouchUpOutside), for: .touchUpOutside)
        // 录制过程中拖拽
        btnSpeak.addTarget(self, action: #selector(touchDragInsideWithEvent(button:event:)), for: .touchDragOutside)
        btnSpeak.addTarget(self, action: #selector(touchDragInsideWithEvent(button:event:)), for: .touchDragInside)
        btnSpeak.isHidden = true
        
        /// 输入框
        topView.addSubview(textView)
        textView.placeholderColor = UIColor(redC: 51, greenC: 51, blueC: 51)
        textView.fontSize = 15.0
        textView.numOfLines = 4
        textView.placeHolder = "请简短的描述你的问题"
        textView.backgroundColor = UIColor(redC: 242, greenC: 242, blueC: 242)
        textView.cornerRadius = 15
        
        textView.textValueDidChanged { (text, height) in
           
            self.textView.snp.updateConstraints({ (make) in
                make.height.equalTo(height)
            })
            
            let h = XZCommon.xz_chatToolBarHeight - self.toolBarBtnH + height
            
            self.topView.snp.updateConstraints({ (make) in
                make.height.equalTo(h)
            })
            
            self.snp.updateConstraints({ (make) in
                make.height.equalTo(h)
            })
            
            // 用户输入值时显示“发送”,没有值显示“+”
            self.btnSendMsg.isHidden = (text.count > 0) ? false : true
            self.btnContactAdd.isHidden = (text.count  > 0) ? true : false
            
            if self.currentTextHeight != height {
                // 记录当前高度
                self.currentTextHeight = height
                // 将 toolBar 的高度传递给控制器，修改 tableView
                // =======
            }
        }
        
        /// + 按钮
        topView.addSubview(btnContactAdd)
        btnContactAdd.setImage(UIImage.init(named: "toolbar_add_background"), for: .normal)
        btnContactAdd.setImage(UIImage.init(named: "toolbar_add_background_selected"), for: .selected)
        btnContactAdd.tag = 122
        btnContactAdd.addTarget(self, action: #selector(didClickVoiceButton), for: .touchUpInside)
        
        /// '发送' 按钮
        topView.addSubview(btnSendMsg)
        btnSendMsg.isHidden = true
        btnSendMsg.tag = 123
        btnSendMsg.backgroundColor = UIColor(redC: 1, greenC: 89, blueC: 213)
        btnSendMsg.layer.masksToBounds = true
        btnSendMsg.layer.cornerRadius = 10
        btnSendMsg.setTitle("发 送", for: .normal)
        btnSendMsg.titleLabel?.font = UIFont.systemFont(ofSize: 14.0)
        btnSendMsg.addTarget(self, action: #selector(didClickVoiceButton), for: .touchUpInside)
        
        setupConstraints()
    }
    
    // 设置布局
    func setupConstraints() {
        // 顶部工具栏
        topView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalToSuperview().offset(1)
            make.height.equalTo(54)
        }
        
        // 底部 + 视图
        keyboardInputView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo(topView.snp.bottom)
            make.height.equalTo(100)
        }
        
        // 转人工
        btnTurnArtifical.snp.makeConstraints { (make) in
            make.left.equalTo(topView).offset(8)
            make.size.equalTo(45)
            make.bottom.equalTo(topView).offset(-5)
        }
        
        let bottomOffset = (XZCommon.xz_chatToolBarHeight - self.toolBarBtnH) / 2.0
        
        /// 语音聊天按钮
        btnVoice.snp.makeConstraints { (make) in
            make.left.equalTo(topView).offset(10)
            make.bottom.equalTo(topView).offset(-bottomOffset)
            make.size.equalTo(toolBarBtnH)
        }
        
        /// 按住说话按钮,默认隐藏
        let btnSpeakW = XZCommon.xz_screenWidth - btnSpeakLeftX - 10 - 50
        btnSpeak.snp.makeConstraints { (make) in
            make.left.equalTo(topView).offset(btnSpeakLeftX)
            make.width.equalTo(btnSpeakW)
            make.centerY.equalTo(topView)
            make.height.equalTo(toolBarBtnH)
        }
        
        /// 输入框
        textView.snp.makeConstraints { (make) in
            make.left.equalTo(topView).offset(btnSpeakLeftX)
            make.width.equalTo(btnSpeakW)
            make.centerY.equalTo(topView)
            make.height.equalTo(toolBarBtnH)
        }
        
        /// + 按钮
        btnContactAdd.snp.makeConstraints { (make) in
            make.right.equalTo(topView).offset(-10)
            make.centerY.equalTo(btnVoice)
            make.size.equalTo(toolBarBtnH)
        }
        
        /// '发送' 按钮
        btnSendMsg.snp.makeConstraints { (make) in
            make.right.equalTo(topView).offset(-10)
            make.bottom.equalTo(topView).offset(-bottomOffset)
            make.height.equalTo(toolBarBtnH)
            make.width.equalTo(45)
        }
        
    }
}










