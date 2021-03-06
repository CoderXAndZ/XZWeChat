//
//  XZTextView.swift
//  XZTextView
//
//  Created by admin on 2018/1/31.
//  Copyright © 2018年 XZ. All rights reserved.
//

import UIKit

class XZTextView: UITextView {
    
    // 回调的block
    private var blockHeightChanged: ((_ text: String, _ textHeight: CGFloat)->())?
    
    func textValueDidChanged(changeHeight:((_ text: String, _ textHeight: CGFloat)->())?) {
        // 记录闭包
        blockHeightChanged = changeHeight
    }
    
    init(frame: CGRect) {
        super.init(frame: frame, textContainer: nil)
        
        setUpUI()
    }
    
    /// textView 的值改变
    @objc func textDidChanged() {

        // 1.占位文字是否隐藏 (text.lengthOfBytes(using: .utf8) > 0)
        placeHolderView.isHidden = self.hasText
        
        // 2.计算高度
        var height = CGFloat(ceilf(Float(sizeThatFits(CGSize(width: bounds.size.width
            , height: CGFloat(MAXFLOAT))).height))) + 1
        
        isScrollEnabled = ((height > maxHeight) && (maxHeight > 0))
            
        if height > maxHeight {
            height = maxHeight
        }
        
        textHeight = height
            
        blockHeightChanged?(text, height)
            
        superview?.layoutIfNeeded()
    }
    
    // 文字高度
    var text_height: CGFloat {
        if textHeight > 0 {
            return textHeight
        }else {
            return 35
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// 占位字符
    var placeHolder: String? {
        didSet{
            if let _ = placeHolder {
                placeholderView()
                placeHolderView.text = placeHolder
                placeHolderView.sizeToFit()
            }
        }
    }
    
    /// 占位字符颜色
    var placeholderColor: UIColor? {
        didSet{
            if let _ = placeHolder {
                placeHolderView.textColor = placeholderColor
            }
        }
    }

    /// 占位字符大小
    var placeholderFontSize: CGFloat? {
        didSet{
            if let _ = placeHolder {
                placeHolderView.font = UIFont.systemFont(ofSize: placeholderFontSize ?? fontSize!)
            }
        }
    }
    
    /// 设置圆角
    var cornerRadius:CGFloat? {
        didSet {
            layer.cornerRadius = cornerRadius ?? 0.0
        }
    }
    
    /// 设置图片
    var hasImage:Bool? {
        didSet {
            if (hasImage != nil) && (hasImage == true) {
                
                addSubview(imageView)
                attributedText = imageText(font: UIFont.systemFont(ofSize: fontSize!))
            }
        }
    }
    
    /// 行数 如果是0，只换行
    var numOfLines: Int? {
        didSet {
            let font = UIFont.systemFont(ofSize: fontSize!)
            
            if numOfLines == 0 {
                maxHeight = CGFloat(MAXFLOAT)
                return
            }
            
            /// 最大行高
            maxHeight = CGFloat(ceilf(Float(font.lineHeight * CGFloat(numOfLines ?? 4) + textContainerInset.top + textContainerInset.bottom)))
        }
    }
    
    /// 字体大小
    var fontSize: CGFloat? {
        didSet {
            font = UIFont.systemFont(ofSize: fontSize ?? 17.0)
        }
    }
    
    /// 文字高度
    private var textHeight: CGFloat = 0
    /// 最大高度
    private var maxHeight: CGFloat = 0
    /// 左侧图片视图
    private let imageView = UIImageView()
    /// 左侧图片
    private let image = UIImage.init(named: "表盘")
    /// 占位字符视图
    private let placeHolderView = UILabel()
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - 图文混排
extension XZTextView {
    
    /// 将当前的图像转换成图片为属性文本
    func imageText(font: UIFont) -> NSAttributedString {
        // 1.判断图像是否存在
        guard let image = image else {
            return NSAttributedString.init(string: "")
        }
        
        // 2.创建文本附件
        let attchment = NSTextAttachment()

        attchment.image = image
        let height = font.lineHeight
        attchment.bounds = CGRect(x: 0, y: -4, width: height, height: height)
        
        // 3.返回图片属性文本
        let attrStrM = NSMutableAttributedString(attributedString: NSAttributedString(attachment: attchment))
        
        // 设置字体属性
        attrStrM.addAttribute(NSAttributedStringKey.font, value: font, range: NSRange(location: 0, length: 1))
        
        // 4.返回属性文本
        return attrStrM
    }
}

// MARK: - 设置页面
extension XZTextView {
    
    func setUpUI() {
        scrollsToTop = false
        isScrollEnabled = false
        showsHorizontalScrollIndicator = false
        enablesReturnKeyAutomatically = true
        layer.borderWidth = 1
        layer.borderColor = UIColor(redC: 222, greenC: 222, blueC: 222).cgColor
        
        // 设置默认的字体大小
        fontSize = 17.0
        
        /// 设置行数
        numOfLines = 0
        
        // 监听 textView 的值的变化
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(textDidChanged),
                                               name: NSNotification.Name.UITextViewTextDidChange,
                                               object: nil)
    }
    
    /// 创建占位视图
    func placeholderView() {
        
        placeHolderView.frame = bounds
        placeHolderView.font = font
        placeHolderView.frame.origin.x = 8
        placeHolderView.frame.origin.y = 7
        placeHolderView.textColor = UIColor.lightGray
        placeHolderView.backgroundColor = UIColor.clear
        addSubview(placeHolderView)
    }
}
