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
    /// 用户点击按钮
    func chatToolBarDidSelectedBtn(btnTag: Int,text: String)
    /// 监听键盘通知，回调给控制器
    func xz_keyboardWillChange(noti:Notification)
    /// 修改 toolBar 回调高度
    func xz_toolBarChangeHeight(height: CGFloat)
    /// 结束录音
    func didStopRecordingVoice(mediaModel: XZMediaModel)
}

class XZChatToolBar: UIView {
    
    weak var delegate: XZChatToolBarDelegate?
    
    /// 开启时间计时器
    @objc func timerReduceOneSecond() {
        print("开启时间计时器 --- \(totoalSecond)")
        let showCounting = shouldShowCounting()
        
        if totoalSecond == 0 { // 60秒倒计时结束,结束录音
            endedRecord = true // 结束录制
            setBtnSpeakHighlighted(value: 3)
            voiceProgress.hiddenProgress = true
            // 停止时间计时器
            stopTimer()
            // 结束录音,回调录音结果
            stopRecordAndCallback()
            return
        }else if showCounting { // 倒计时
            currentState = XZVoiceRecordState.recordCounting
            voiceProgress.time = "\(totoalSecond)"
            
            if canceled { // 当前拖拽到 按钮 外
                voiceProgress.voiceRecordState = XZVoiceRecordState.releaseToCancel
            }else {
                voiceProgress.voiceRecordState = currentState
            }
        }else { // 正常显示声音
            if currentState != XZVoiceRecordState.releaseToCancel {
                voiceProgress.progress = manager.powerChanged()
                print("正常显示声音",voiceProgress.progress)
            }
        }
        totoalSecond = totoalSecond - 1
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
                delegate?.chatToolBarDidSelectedBtn(btnTag: button.tag,text: "")
                break
            case 122: // + 按钮
                button.isSelected = !button.isSelected
                // 回收键盘
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
                delegate?.chatToolBarDidSelectedBtn(btnTag: button.tag, text: textView.text)
                // 清空输入框
                textView.text = ""
                // 发送通知
                NotificationCenter.default.post(name: NSNotification.Name.UITextViewTextDidChange, object: textView)
                break
            default:
                break
        }
    }
    
    /// 开始录音
    @objc func speakerTouchDown() {
        stopTimer()
        
        currentState = XZVoiceRecordState.recording
        updateButtonState(state: currentState)
        
        manager.startRecordWithFileName(fileName: XZFileTools.currentRecordFileName()) {
            print("开始录音回调")
            // 开启时间计时器
            self.startTimer()
        }
    }
    
    /// 结束录音 -> 松开结束
    @objc func speakerTouchUpInside() {
        if endedRecord {
            return
        }
        
        endedRecord = true
        stopRecordAndCallback()
    }
    
    @objc func speakerTouchUpOutside() {
        if endedRecord { // 60s结束录制
            return
        }
        
        // 取消
        stopTimer()
        
        manager.cancelCurrentRecording()
        manager.removeCurrentRecordFile()
        
        currentState = XZVoiceRecordState.normal
        updateButtonState(state: currentState)
    }
    
    /// 录制过程中拖拽
    @objc func touchDragInsideWithEvent(button:UIButton,event:UIEvent) {
        
        if endedRecord {
            return
        }
        
        guard let touch = event.allTouches?.first else {
            return
        }
        let point = touch.location(in: btnSpeak)
        // 判断当前触摸点是否在 button 的 bounds 范围内
        let isInside:Bool = btnSpeak.bounds.contains(point)
        
        if isInside { // 按钮内
            canceled = false
            
            if shouldShowCounting() { // 显示倒计时
               currentState = XZVoiceRecordState.recordCounting
            }else {
                currentState = XZVoiceRecordState.recording
            }
        }else { // 按钮外
            currentState = XZVoiceRecordState.releaseToCancel
            canceled = true
        }
        
        updateButtonState(state: currentState)
    }
    
    /// 转人工
    var transferSuccessed: Bool = false {
        didSet {
            if transferSuccessed { // 成功
                btnTurnArtifical.isHidden = true
                btnVoice.isHidden = false
                // 设置是跟机器人聊天还是跟客服聊天
                keyboardInputView.isRobot = false
            }else { // 失败
                btnTurnArtifical.isHidden = false
                btnVoice.isHidden = true
                // 设置是跟机器人聊天还是跟客服聊天
                keyboardInputView.isRobot = true
            }
        }
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
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        // 注销通知
        NotificationCenter.default.removeObserver(self)
    }
    
    /// 输入框
    private let textView = XZTextView(frame: .zero)
    /// 顶部试图
    private let topView = UIView()
    /// 语音聊天按钮
    private let btnVoice = UIButton(type: .custom)
    /// 按住说话按钮,默认隐藏
    private let btnSpeak = UIButton(type: .custom)
    /// 发送按钮
    private let btnSendMsg = UIButton(type: .custom)
    /// 加号按钮
    private let btnContactAdd = UIButton(type: .custom)
    /// 转人工
    private let btnTurnArtifical = XZButton(type: .custom)
    /// 父视图
    private var barSuperView: UIView!
    /// 当前文字高度
    private var currentTextHeight: CGFloat = 0
    /// normal图片
    private var btnSpeakImg: UIImage = UIImage.init(named: "compose_emotion_table_left_normal")!
    /// highlighted图片
    private var highlightedImage: UIImage = UIImage.init(named: "compose_emotion_table_left_selected")!
    
    /// 60s 倒计时
    private var timerReduce: Timer?
    // 倒计时
    private var totoalSecond: Int = 0
    // 取消录制
    private var canceled: Bool = false
    // 结束录制
    private var endedRecord: Bool = false
    // 当前状态
    private var currentState = XZVoiceRecordState.normal

    /// 底部 + 视图
    var keyboardInputView = XZKeyboardInputView(frame: CGRect.zero)
    /// 录音提示页面
    private let voiceProgress = XZVoiceProgress(frame: CGRect(x: 0, y: 0, width: 155, height: 155))
    private let toolBarBtnH: CGFloat = 35.0 // 顶部工具栏按钮和输入框初始高度
    private let toolBarBottom: CGFloat = 100.0 // 底部视图
    private let btnSpeakLeftX: CGFloat = 55.0 // 按住说话左边距
    private let minRecordDuration = 1.0 // 最短录音时间
    private let maxRecordDuration = 60 // 最长录音时间
    private let remainCountingDuration = 10 // 剩余多少秒开始倒计时
    /// 录音
    private let manager = XZVoiceRecorderManager.sharedManager
}

// MARK: - 录音
extension XZChatToolBar {
    
    /// 停止录制并回调
    func stopRecordAndCallback() {
        stopTimer()
        
        if canceled == false { // 不是取消录制调用，是倒计时结束调用
            manager.delegate = self
            manager.stopRecordingWithCompletion(completion: { (recordPath) in
                if recordPath.count > 0 { // 录音完成
                    let modelVioce = XZMediaModel()
                    modelVioce.mediaName = self.manager.currentFileName()
                    modelVioce.mediaType = 0
                    modelVioce.mediaPath = recordPath
                    let wavPath = (recordPath as NSString).replacingOccurrences(of: "amr", with: "wav")
                    let time:TimeInterval = XZFileTools.durationWithVoiceURL(voiceURL: URL(fileURLWithPath: wavPath))
                    modelVioce.mediaDuration = time
                    // 录制时间大于1秒才进行发送
                    if modelVioce.mediaDuration > 1.0 {
                        self.delegate?.didStopRecordingVoice(mediaModel: modelVioce)
                    }else { // 录制时间太短
                        self.manager.isNeedCancelRecording = true
                        self.manager.removeCurrentRecordFile()
                        self.currentState = XZVoiceRecordState.recordTooShort
                        self.updateButtonState(state: self.currentState)
                    }
                    print("回调")
                }
            })
            
            currentState = XZVoiceRecordState.normal
            updateButtonState(state: currentState)
        }else { // 取消调用结束
            manager.cancelCurrentRecording()
        }
    }
    
}

// 录音过程中被电话中断
extension XZChatToolBar: XZVoiceRecorderManagerDelegate {
    // 录音被打断
    func audioRecorderInterrupted(tips: String) {
        // 停止计时器
        stopTimer()
        currentState = XZVoiceRecordState.normal
        updateButtonState(state: currentState)
    }
}

// MARK: - 时间计时器
extension XZChatToolBar {
    /// 是否倒计时
    func shouldShowCounting() -> Bool {
        if totoalSecond <= remainCountingDuration && totoalSecond > 0 && currentState != XZVoiceRecordState.releaseToCancel {
           return true
        }
        return false
    }
    
    /// 开启时间计时器
    func startTimer() {
        timerReduce = Timer.scheduledTimer(timeInterval: minRecordDuration, target: self, selector: #selector(timerReduceOneSecond), userInfo: nil, repeats: true)
    }
    
    /// 关闭计时器
    func stopTimer() {
        if timerReduce != nil {
            timerReduce?.invalidate()
            timerReduce = nil
        }
        
        totoalSecond = maxRecordDuration
        canceled = false
        endedRecord = false
        manager.delegate = nil
    }
    
}

// MARK: - 监听键盘通知
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
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.05) {
            self.snp.remakeConstraints({[weak self] (make) in
                make.left.right.equalTo((self?.barSuperView)!)
                make.bottom.equalTo((self?.barSuperView)!).offset(-height)
                make.height.equalTo(XZCommon.xz_chatToolBarHeight)
            })
        }
        
        delegate?.xz_keyboardWillChange(noti: aNotification)
        
        // 发送和+按钮的 隐藏 和 显示
        self.btnSendMsg.isHidden = (textView.text.count > 0) ? false : true
        self.btnContactAdd.isHidden = (textView.text.count  > 0) ? true : false
    }
    
    /// 键盘退出时调用
    @objc func keyboardWillHide(aNotification:Notification) {
        self.snp.remakeConstraints { (make) in
            make.left.bottom.right.equalTo(barSuperView)
            make.height.equalTo(XZCommon.xz_chatToolBarHeight)
        }
       
        delegate?.xz_keyboardWillChange(noti: aNotification)
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
            
            // 将toolbar的高度传递给控制器，修改tableView
            delegate?.xz_toolBarChangeHeight(height: height + 100)
            
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
            
            // 将toolbar的高度传递给控制器，修改tableView
            delegate?.xz_toolBarChangeHeight(height: height)
        }
    }
}

// MARK: - 设置页面
extension XZChatToolBar {
    
    /// 更新按钮状态
    func updateButtonState(state: XZVoiceRecordState) {
        
        if state == XZVoiceRecordState.normal {
            
            setBtnSpeakHighlighted(value: 2)
            voiceProgress.hiddenProgress = true
            
        }else if state == XZVoiceRecordState.recording {  // 正在录音
            
            voiceProgress.hiddenProgress = false
            voiceProgress.voiceRecordState = state
            setBtnSpeakHighlighted(value: 1)
            
        }else if state == XZVoiceRecordState.releaseToCancel { // 取消发送
            
            setBtnSpeakHighlighted(value: 1)
            voiceProgress.hiddenProgress = false
            voiceProgress.voiceRecordState = state
            
        }else if state == XZVoiceRecordState.recordCounting { // 倒计时
            
            setBtnSpeakHighlighted(value: 1)
            voiceProgress.hiddenProgress = false
            voiceProgress.time = "\(totoalSecond)"
            voiceProgress.voiceRecordState = state
            
        }else if state == XZVoiceRecordState.recordTooShort { // 时间太短
            
            voiceProgress.hiddenProgress = false
            voiceProgress.voiceRecordState = state
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2, execute: {
                self.voiceProgress.hiddenProgress = true
            })
        }
    }
    
    /// 设置button的高亮 === YES 高亮 NO 不高亮
    func setBtnSpeakHighlighted(value: Int) {
        switch value {
            case 1: // 1 长按状态
                btnSpeak.setBackgroundImage(highlightedImage, for: .normal)
                btnSpeak.setTitle("松开 结束", for: .normal)
                break
            case 2: // 2 正常状态
                btnSpeak.setBackgroundImage(btnSpeakImg, for: .normal)
                btnSpeak.setTitle("按住 说话", for: .normal)
                break
            case 3: // 3 高亮状态
                btnSpeak.setBackgroundImage(btnSpeakImg, for: .highlighted)
                btnSpeak.setTitle("按住 说话", for: .highlighted)
                break
            default:
                break
        }
    }
    
    /// 设置页面
    func setupChatToolBar() {
        backgroundColor = UIColor.white
        
        let line = UIView()
        addSubview(line)
        line.frame = CGRect(x: 0, y: 0, width: XZCommon.xz_screenWidth, height: 1)
        line.backgroundColor = UIColor(redC: 191, greenC: 191, blueC: 191, isRandom: false)
        
        // 顶部工具栏
        addSubview(topView)
        topView.backgroundColor = UIColor.white
        
        // 底部 + 视图
        addSubview(keyboardInputView)
        keyboardInputView.isRobot = true
        keyboardInputView.backgroundColor = UIColor.orange
//        keyboardInputView.delegate = self
        
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
            
            print("text.count",text.count)
            
            if self.currentTextHeight != height {
                // 记录当前高度
                self.currentTextHeight = height
                // 将 toolBar 的高度传递给控制器，修改 tableView
                self.delegate?.xz_toolBarChangeHeight(height: self.toolBar_height)
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
        
        barSuperView.addSubview(voiceProgress)
        voiceProgress.center = CGPoint(x: barSuperView.center.x, y: barSuperView.center.y)
//        voiceProgress.backgroundColor = UIColor.red
        voiceProgress.hiddenProgress = true
        
        setupConstraints()
    }
    
    /// 设置布局
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










