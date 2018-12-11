//
//  MessageView.swift
//  ComponentKit
//
//  Created by William Lee on 21/12/17.
//  Copyright © 2018 William Lee. All rights reserved.
//

import UIKit

class MessageView: UIView {
  
  private let titleLabel: UILabel = UILabel()
  private let messageLabel: UILabel = UILabel()
  private let contentView: UIView = UIView()
  
  private static var foreground: UIColor = UIColor.white
  private static var background: UIColor = UIColor.black.withAlphaComponent(0.6)
  
  public override init(frame: CGRect) {
    super.init(frame: frame)
    
    self.setupUI()
  }
  
  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
}

// MARK: - Appearance
extension MessageView {
  
  class func `default`(foreground: UIColor = UIColor.white, background: UIColor = UIColor.black.withAlphaComponent(0.6)) {
    
    self.foreground = foreground
    self.background = background
  }
  
}

// MARK: - Setting
extension MessageView {
  
  func setup(title: String?, message: String?) {
    
    self.titleLabel.text = title
    self.messageLabel.text = message
  }
  
  func show() {
    
    self.isHidden = false
  }
  
  func hide() {
    
    self.isHidden = true
  }
  
}

// MARK: - Setup
private extension MessageView {
  
  func setupUI() -> Void {
    
    //ContentView
    self.contentView.backgroundColor = MessageView.background
    self.contentView.layer.cornerRadius = 5
    self.contentView.layer.shadowColor = UIColor.black.cgColor
    self.contentView.layer.shadowOffset = CGSize(width: 1, height: 1)
    self.contentView.layer.shadowRadius = 3
    self.contentView.layer.shadowOpacity = 0.5    
    self.addSubview(self.contentView)
    self.contentView.layout.add { (make) in
      
      make.leading(60).trailing(-60).centerY().equal(self)
    }
    
    //Title
    self.titleLabel.textAlignment = .center
    self.titleLabel.font = UIFont.systemFont(ofSize: 17)
    self.titleLabel.textColor = MessageView.foreground
    self.contentView.addSubview(self.titleLabel)
    self.titleLabel.layout.add { (make) in
      
      make.top(30).leading().trailing().equal(self.contentView)
    }
    
    //MessageLabel
    self.messageLabel.textAlignment = .center
    self.messageLabel.numberOfLines = 0
    self.messageLabel.font = UIFont.systemFont(ofSize: 14)
    self.messageLabel.textColor = MessageView.foreground
    self.contentView.addSubview(self.messageLabel)
    self.messageLabel.layout.add { (make) in
      
      make.top(8).equal(self.titleLabel).bottom()
      make.leading(13).trailing(-13).bottom(-30).equal(self.contentView)
    }
  }
  
}
