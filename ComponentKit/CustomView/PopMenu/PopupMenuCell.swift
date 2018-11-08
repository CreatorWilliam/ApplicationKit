//
//  PopupMenuCell.swift
//  VideoModule
//
//  Created by Hiu on 2018/6/6.
//  Copyright © 2018年 飞进科技. All rights reserved.
//

import UIKit

class PopupMenuCell: UITableViewCell {
  
  var isShowSeparator: Bool = true {
    
    didSet{ self.setNeedsDisplay() }
  }
  
  var separatorColor: UIColor = UIColor.lightGray {
    
    didSet{ self.setNeedsDisplay() }
  }
  
  override func draw(_ rect: CGRect) {
    super.draw(rect)
    
    if isShowSeparator == false { return }
    
    let bezierPath = UIBezierPath(rect: CGRect(x: 0, y: rect.size.height - 0.5, width: rect.size.width, height: 0.5))
    self.separatorColor.setFill()
    bezierPath.fill(with: CGBlendMode.normal, alpha: 1)
    bezierPath.close()
  }
  
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    
    self.setNeedsDisplay()
    self.selectionStyle = .none
    self.textLabel?.numberOfLines = 0
    self.backgroundColor = .clear
    self.textLabel?.textAlignment = .center
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
}

// MARK: - Public
extension PopupMenuCell {
  
  func updateText(_ color: UIColor) {
    
    self.textLabel?.textColor = color
  }
  
  func updateText(_ font: UIFont) {
    
    self.textLabel?.font = font
  }
  
  func updateText(_ text: String) {
    
    self.textLabel?.text = text
  }
  
  func updateImage(_ name: String? = nil) {
    
    if let name = name {
      
      self.imageView?.image = UIImage(named: name)
      
    } else {
      
      self.imageView?.image = nil
    }
  }
  
}














