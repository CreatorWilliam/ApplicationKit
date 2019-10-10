//
//  MessageView.swift
//  ComponentKit
//
//  Created by William Lee on 21/12/17.
//  Copyright © 2018 William Lee. All rights reserved.
//

import UIKit

class MessageView: UIView {
  
  private let contentButton = UIButton(type: .custom)
  private let contentView: UIView = UIView()
  
  private static var foreground: UIColor = UIColor.white
  private static var background: UIColor = UIColor.black.withAlphaComponent(0.6)
  
  public override init(frame: CGRect) {
    super.init(frame: frame)
    
    setupUI()
  }
  
  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
}

// MARK: - Appearance
extension MessageView {
  
  class func `default`(foreground: UIColor = UIColor.white,
                       background: UIColor = UIColor.black.withAlphaComponent(0.6)) {
    
    self.foreground = foreground
    self.background = background
  }
  
}

// MARK: - Setting
extension MessageView {
  
  func setup(title: String?, message: String?) {
    
    let style = NSMutableParagraphStyle()
    style.alignment = .center
    style.paragraphSpacing = 15
    style.lineSpacing = 5
    
    let attributedText = NSMutableAttributedString()
    if let title = title {
      
      attributedText.append(NSAttributedString(string: title,
                                               attributes: [.font: UIFont.systemFont(ofSize: 17),
                                                            .foregroundColor: MessageView.foreground,
                                                            .paragraphStyle: style]))
    }
    
    if var message = message {
      
      if title != nil {
        
        message = "\n\(message)"
      }
      
      attributedText.append(NSAttributedString(string: message,
                                               attributes: [.font: UIFont.systemFont(ofSize: 14),
                                                            .foregroundColor: MessageView.foreground,
                                                            .paragraphStyle: style]))
    }
    
    contentButton.setAttributedTitle(attributedText, for: .normal)
  }
  
  func show() {
    
    isHidden = false
  }
  
  func hide() {
    
    isHidden = true
  }
  
}

// MARK: - Setup
private extension MessageView {
  
  func setupUI() -> Void {
    
    //ContentView
    contentView.backgroundColor = MessageView.background
    contentView.layer.cornerRadius = 5
    contentView.layer.shadowColor = UIColor.black.cgColor
    contentView.layer.shadowOffset = CGSize(width: 1, height: 1)
    contentView.layer.shadowRadius = 3
    contentView.layer.shadowOpacity = 0.5
    addSubview(contentView)
    contentView.layout.add { (make) in
      make.centerX().centerY().equal(self)
      make.leading(60).greaterThanOrEqual(self)
      make.trailing(-60).lessThanOrEqual(self)
    }
    
    //
    contentButton.isUserInteractionEnabled = false
    contentButton.setTitleColor(MessageView.foreground, for: .normal)
    addSubview(contentButton)
    contentButton.layout.add { (make) in
      make.top(5).bottom(-5).leading(8).trailing(-8).equal(contentView)
    }
    
  }
  
}
