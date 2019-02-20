//
//  PopupMenuCell.swift
//  VideoModule
//
//  Created by Hiu on 2018/6/6.
//  Copyright © 2018年 Hiu. All rights reserved.
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
  
  var normalColor: UIColor?
  var selectedColor: UIColor?
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    
    self.setNeedsDisplay()
    self.selectionStyle = .none
    self.textLabel?.numberOfLines = 0
    self.backgroundColor = .clear
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    self.textLabel?.textColor = selected ? self.selectedColor : self.normalColor
  }
  
}

// MARK: - Public
extension PopupMenuCell {
  
  func update(with item: PopupMenuItem) {
    
    self.textLabel?.text = item.title
    if let imageName = item.imageName {
      
      self.imageView?.image = UIImage(named: imageName)
      
    } else if let imageURL = item.imageURL {
      
      self.imageView?.setImage(with: imageURL)
      
    } else {
      
      self.imageView?.image = nil
    }
    
  }
  
  func updateText(_ alignment: NSTextAlignment) {
    
    self.textLabel?.textAlignment = alignment
  }
  
  func updateText(_ font: UIFont) {
    
    self.textLabel?.font = font
  }
  
}
