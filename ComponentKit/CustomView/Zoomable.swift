//
//  Zoomable.swift
//  ComponentKit
//
//  Created by William Lee on 30/03/2018.
//  Copyright © 2018 William Lee. All rights reserved.
//

import UIKit

public protocol Zoomable {
  
  /// 进行放大的视图，使用Frame
  var zoomView: UIView { get }
  /// zoomView的容器，ZoomView的放大效果根据其容器的大小计算
  var zoomViewContainer: UIView { get }
  
  // 根据偏移放大
  func zoom(with offset: CGFloat)
  
}

public extension Zoomable {
  
  // 根据偏移放大，默认偏移多少，高度就增加该偏移量，宽度按比例增加偏移量
  func zoom(with offset: CGFloat) {
    
    let size = self.zoomViewContainer.bounds.size

    guard size.height > 0 else { return }
    self.zoomView.layer.anchorPoint = CGPoint(x: 0.5, y: 1)
    self.zoomView.center = CGPoint(x: size.width / 2, y: size.height)
    
    //向下偏移放大
    if (offset > 0) { return }
    
    let heightOffset = abs(offset)
    let widhtOffset = abs(offset) * (size.width / size.height)
    
    self.zoomView.bounds.size.height = heightOffset + size.height
    self.zoomView.bounds.size.width = widhtOffset + size.width
    
  }
  
}
