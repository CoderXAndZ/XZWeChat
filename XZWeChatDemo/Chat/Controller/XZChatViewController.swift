//
//  XZChatViewController.swift
//  XZWeChatDemo
//
//  Created by admin on 2018/8/8.
//  Copyright © 2018年 XZ. All rights reserved.
//

import UIKit

class XZChatViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        //
        view.addSubview(toolBar)
        toolBar.delegate = self
        toolBar.keyboardInputView.delegate = self
    }

    private lazy var toolBar = XZChatToolBar(frame: CGRect(x: 0, y: XZCommon.xz_screenHeight - 55, width: XZCommon.xz_screenWidth, height: 155), barSuperView: view)
}

/// XZChatToolBarDelegate, XZKeyboardInputViewDelegate
extension XZChatViewController:XZChatToolBarDelegate,XZKeyboardInputViewDelegate {
    /// 点击"发送"和 "转人工"
    func chatToolBarDidSelectedBtn(btnTag: Int, text: String) {
        if btnTag == 121 { // 转人工
            print("请求转人工数据")
            // 请求成功，设置页面
            toolBar.transferSuccessed = true
        }else if btnTag == 123 { // 发送
            print("点击了 发送：",text)
            print("请求将数据上传至服务器的接口")
        }
    }
    
    /// 监听键盘，修改 tableView 高度
    func xz_keyboardWillChange(noti: Notification) {
        print("监听键盘，修改 tableView 高度")
    }
    
    /// 修改 toolBar 高度调用
    func xz_toolBarChangeHeight(height: CGFloat) {
        print("修改 toolBar 高度")
    }
    
    /// 底部 加号 视图的点击事件
    func keyboardInputViewDidSelectedBtn(btnTag: Int) {
        print("选中按钮的tag: ",btnTag)
    }
}
