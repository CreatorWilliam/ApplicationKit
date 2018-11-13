//
//  CodeInputView.swift
//  ComponentKit
//
//  Created by William Lee on 2018/11/8.
//  Copyright © 2018 William Lee. All rights reserved.
//

import UIKit

public protocol CodeInputViewDelegate: class {
    
    func codeInputView(_ codeInputView: CodeInputView, didComplete code: String)
    
}

public class CodeInputView: UIView {
    
    public weak var delegate: CodeInputViewDelegate?
    
    // 是否明文
    public var isSecureTextEntry = false { didSet { self.updateContent() } }
  
    public var text: String? {

      set {
        guard newValue?.count ?? 0 <= self.count else { return }
        self.textField.text =  newValue
        self.textField.sendActions(for: .editingChanged)

      }
      get {
        
        return self.textField.text
      }
    }
  
    @discardableResult
    public override func becomeFirstResponder() -> Bool { return self.textField.becomeFirstResponder() }
    
    @discardableResult
    public override func resignFirstResponder() -> Bool { return self.textField.resignFirstResponder() }
    
    private var count: Int = 0
    private var boxWidth: CGFloat = 44.0
    
    private let textField = UITextField()
    /// 用于显示数字和边框
    private var boxLabels: [UILabel] = []
    /// 用于密文显示
    private var pointViews: [UIView] = []
    
    public init(with count: Int, boxWidth: CGFloat = 44) {
        super.init(frame: .zero)
        
        self.count = count
        self.boxWidth = boxWidth
        self.setupUI()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: - Public
public extension CodeInputView {
    
    /// 清除所有输入的信息
    func clear() {
        
        self.textField.text = ""
        self.updateContent()
    }
    
}

// MARK: - Action
private extension CodeInputView {
    
    @objc func textFieldDidChange(_ textField: UITextField) -> Void {
        
        if (self.textField.text ?? "").count == self.count {
            
            self.textField.resignFirstResponder()
            self.delegate?.codeInputView(self, didComplete: self.textField.text ?? "")
        }
        
        self.updateContent()
    }
    
}

//MARK: UITextFieldDelegate
extension CodeInputView: UITextFieldDelegate {
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if string.count == 0 { return true }
        
        if (textField.text?.count ?? 0) > self.count { return false }
        
        return true
    }
    
}


// MARK: - Setup
private extension CodeInputView {
    
    func setupUI() {
        
        self.layer.borderColor = UIColor(0x4b8bf9).cgColor
        self.layer.borderWidth = 1
        self.layer.cornerRadius = 5
        self.layer.backgroundColor = UIColor(0xbfbec3).cgColor
        self.clipsToBounds = true
        
        self.textField.keyboardType = .numberPad
        self.textField.delegate = self
        self.textField.textColor = .clear
        self.textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        self.addSubview(self.textField)
        self.textField.layout.add { (make) in
            make.top().bottom().leading().trailing().equal(self)
        }
        
        (0 ..< self.count).forEach({_ in self.pointViews.append(UIView()) })
        (0 ..< self.count).forEach({_ in self.boxLabels.append(UILabel()) })
        
        for index in 0 ..< self.count {
            
            let boxView = self.boxLabels[index]
            boxView.isUserInteractionEnabled = false
            boxView.layer.backgroundColor = UIColor.white.cgColor
            boxView.font = UIFont.systemFont(ofSize: 14)
            boxView.textAlignment = .center
            boxView.textColor = .black
            self.addSubview(boxView)
            boxView.layout.add({ (make) in
                
                if index == 0 { make.leading(1).equal(self) }
                else { make.leading(1).equal(self.boxLabels[index - 1]).trailing() }
                
                if index == self.pointViews.count - 1 { make.trailing(-1).equal(self) }
                make.top().bottom().equal(self)
                make.width(self.boxWidth).height(self.boxWidth)
            })
            
            let pointView = self.pointViews[index]
            pointView.isUserInteractionEnabled = false
            pointView.layer.backgroundColor = UIColor.black.cgColor
            pointView.layer.cornerRadius = 5
            pointView.isHidden = true
            boxView.addSubview(pointView)
            pointView.layout.add({ (make) in
                make.centerX().centerY().equal(boxView)
                make.height(10).width(10)
            })
        }
    }
    
    /// 更具self.textField.text更新内容
    func updateContent() {
        
        let text = self.textField.text ?? ""
        
        for (index, subtext) in text.enumerated() {
            
            self.pointViews[index].isHidden = !self.isSecureTextEntry
            self.boxLabels[index].text = self.isSecureTextEntry ? nil : String(subtext)
        }
        
        for index in text.count..<self.pointViews.count {
            
            self.pointViews[index].isHidden = true
            self.boxLabels[index].text = nil
        }
    }
    
}

