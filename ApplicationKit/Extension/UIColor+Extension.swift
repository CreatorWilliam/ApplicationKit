//
//  UIColor+Extension.swift
//  ComponentKit
//
//  Created by William Lee on 19/12/17.
//  Copyright © 2018 William Lee. All rights reserved.
//

import UIKit

public extension UIColor {
  
  /// 随机颜色
  ///
  /// - Returns: 随机生成的颜色
  class var random: UIColor {
    
    let red = Int(arc4random() % 256)
    let green = Int(arc4random() % 256)
    let blue = Int(arc4random() % 256)
    //let alpha = Float(arc4random() % 101) / 100.0
    
    return UIColor(red, green, blue)
  }
  
  /// 十六进制
  ///
  /// - Parameters:
  ///   - rgb: 包含红绿蓝色值
  ///   - alpha: 透明度，默认1.0
  /// - Returns: 颜色
  convenience init(_ rgb: Int, alpha: CGFloat = 1.0) {
    
    let red: Int = (rgb & 0xff0000) >> 16
    let green: Int = (rgb & 0x00ff00) >> 8
    let blue: Int = (rgb & 0x0000ff)
    self.init(red: CGFloat(red) / 255.0,
                   green: CGFloat(green) / 255.0,
                   blue: CGFloat(blue) / 255.0,
                   alpha: alpha)
  }
  
  /// 十进制
  ///
  /// - Parameters:
  ///   - red: 红值
  ///   - green: 绿值
  ///   - blue: 蓝值
  ///   - alpha: 透明度，默认1.0
  /// - Returns: 颜色
  convenience init(_ red: Int, _ green: Int, _ blue: Int, _ alpha: CGFloat = 1.0) {
    
    self.init(red: CGFloat(red) / 255.0,
                   green: CGFloat(green) / 255.0,
                   blue: CGFloat(blue) / 255.0,
                   alpha: alpha)
  }
  
}
