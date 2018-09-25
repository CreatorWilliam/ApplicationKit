//
//  OptionActionView.swift
//  ComponentKit
//
//  Created by William Lee on 23/03/2018.
//  Copyright © 2018 William Lee. All rights reserved.
//

import UIKit

class OptionActionView: UIView {
  
  private let imageView = UIImageView()
  private let titleLabel = UILabel()
  private let badgeView = UIButton(type: .custom)
  private let actionView = UIButton(type: .custom)
  
  override init(frame: CGRect) {
    super.init(frame: frame)

    self.setupView()
    self.setupLayout()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
}

// MARK: - Public
extension OptionActionView {
  
  func update(image: String?, title: String, target: Any, action: Selector) {
    
    if let image = image {
      
      self.update(image: image)
      self.titleLabel.layout.update { (make) in
        
        make.leading(50).centerY().equal(self)
      }
      
    }
    self.update(title: title)
    self.actionView.addTarget(target, action: action, for: .touchUpInside)
  }
  
  func update(image: String) {
    
    self.imageView.image = UIImage(named: image)
  }
  
  func update(title: String) {
    
    self.titleLabel.text = title
  }
  
  func update(badge: Int) {
    
    self.badgeView.isHidden = badge < 1
    self.badgeView.setTitle("\(badge)", for: .normal)
  }
  
}

// MARK: - Setup
private extension OptionActionView {
  
  func setupView() {
    
    self.backgroundColor = .white
    
    self.addSubview(self.imageView)
    
    self.titleLabel.font = UIFont.systemFont(ofSize: 15)
    self.titleLabel.textColor = UIColor(0x333333)
    self.addSubview(self.titleLabel)
    
    self.badgeView.isUserInteractionEnabled = false
    self.badgeView.isHidden = true
    self.badgeView.titleLabel?.font = UIFont.systemFont(ofSize: 10)
    self.badgeView.layer.backgroundColor = UIColor.red.cgColor
    self.badgeView.contentEdgeInsets = UIEdgeInsets(top: 0, left: 3, bottom: 0, right: 3)
    self.badgeView.layer.cornerRadius = 7
    self.addSubview(self.badgeView)
    
    self.addSubview(self.actionView)
  }
  
  func setupLayout() {
    
    self.imageView.layout.add { (make) in
      
      make.leading(15).centerY().equal(self)
    }
    
    self.titleLabel.layout.add { (make) in
      
      make.leading(15).centerY().equal(self)
      make.trailing(-20).lessThanOrEqual(self)
    }
    
    self.badgeView.layout.add { (make) in
      
      make.centerX().equal(self.titleLabel).trailing()
      make.centerY().equal(self.titleLabel).top()
      make.height(14)
    }
    
    self.actionView.layout.add { (make) in
      
      make.top().bottom().leading().trailing().equal(self)
    }
  }
  
}

// MARK: - Action
private extension OptionActionView {
  
}














