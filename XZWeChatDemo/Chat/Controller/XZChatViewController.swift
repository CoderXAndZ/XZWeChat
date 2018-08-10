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
    }

    private lazy var toolBar = XZChatToolBar(frame: CGRect(x: 0, y: XZCommon.xz_screenHeight - 55, width: XZCommon.xz_screenWidth, height: 155), barSuperView: view)
}

