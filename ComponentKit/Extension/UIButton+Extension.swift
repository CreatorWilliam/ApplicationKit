//
//  UIButton+Extension.swift
//  ComponentKit
//
//  Created by William Lee on 22/12/17.
//  Copyright © 2018 William Lee. All rights reserved.
//

import UIKit

// MARK: - PositionLayout
public extension UIButton {
  
  enum ButtonImagePosition {
    
    /// 图片在左，文字在右，默认
    case left
    /// 图片在右，文字在左
    case right
    /// 图片在上，文字在下
    case top
    /// 图片在下，文字在上
    case bottom
  }
  
  func setImage(position: ButtonImagePosition, with margin: CGFloat) {
    
    let imageSize = self.imageView?.image?.size ?? CGSize.zero
    
    let labelSize = self.titleLabel?.sizeThatFits(CGSize(width: 999, height: 999)) ?? CGSize.zero
    //[self.titleLabel.text sizeWithAttributes:@{NSFontAttributeName : self.titleLabel.font}]
    
    //image中心移动的x距离
    let imageOffsetX = (imageSize.width + labelSize.width) / 2 - imageSize.width / 2
    //image中心移动的y距离
    let imageOffsetY = imageSize.height / 2 + margin / 2
    //label中心移动的x距离
    let labelOffsetX = (imageSize.width + labelSize.width / 2) - (imageSize.width + labelSize.width) / 2
    //label中心移动的y距离
    let labelOffsetY = labelSize.height / 2 + margin / 2
    
    let tempWidth = max(labelSize.width, imageSize.width)
    let tempHeight = max(labelSize.height, imageSize.height)
    let changedWidth = labelSize.width + imageSize.width - tempWidth
    let changedHeight = labelSize.height + imageSize.height + margin - tempHeight
    
    switch (position) {
      
    case .left:
      
      self.imageEdgeInsets = UIEdgeInsets(top: 0, left: -margin/2, bottom: 0, right: margin/2)
      self.titleEdgeInsets = UIEdgeInsets(top: 0, left: margin/2, bottom: 0, right: -margin/2)
      self.contentEdgeInsets = UIEdgeInsets(top: 0, left: margin/2, bottom: 0, right: margin/2)
      
    case .right:
      
      self.imageEdgeInsets = UIEdgeInsets(top: 0, left: labelSize.width + margin/2, bottom: 0, right: -(labelSize.width + margin/2))
      self.titleEdgeInsets = UIEdgeInsets(top: 0, left: -(imageSize.width + margin/2), bottom: 0, right: imageSize.width + margin/2)
      self.contentEdgeInsets = UIEdgeInsets(top: 0, left: margin/2, bottom: 0, right: margin/2)
      
    case .top:
      
      self.imageEdgeInsets = UIEdgeInsets(top: -imageOffsetY, left: imageOffsetX, bottom: imageOffsetY, right: -imageOffsetX)
      self.titleEdgeInsets = UIEdgeInsets(top: labelOffsetY, left: -labelOffsetX, bottom: -labelOffsetY, right: labelOffsetX)
      self.contentEdgeInsets = UIEdgeInsets(top: imageOffsetY, left: -changedWidth/2, bottom: changedHeight-imageOffsetY, right: -changedWidth/2)
      
    case .bottom:
      
      self.imageEdgeInsets = UIEdgeInsets(top: imageOffsetY, left: imageOffsetX, bottom: -imageOffsetY, right: -imageOffsetX)
      self.titleEdgeInsets = UIEdgeInsets(top: -labelOffsetY, left: -labelOffsetX, bottom: labelOffsetY, right: labelOffsetX)
      self.contentEdgeInsets = UIEdgeInsets(top: changedHeight-imageOffsetY, left: -changedWidth/2, bottom: imageOffsetY, right: -changedWidth/2)
      
    }
    
  }
  
}
