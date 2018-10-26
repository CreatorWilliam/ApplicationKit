//
//  Font.swift
//  ComponentKit
//
//  Created by William Lee on 07/02/2018.
//  Copyright © 2018 William Lee. All rights reserved.
//

import Foundation

public struct Font {
  
  // 字体大小
  var size: CGFloat = 14

  // 字体名称
  var name: String?
}

public extension Font {
  
  /// 系统字体
  ///
  /// - Parameters:
  ///   - size: 设计稿中字体大小
  ///   - isBold: 是否为粗体，默认为否
  ///   - isAdapted: 是否为适配模式，默认为是，适配模式会根据屏幕缩放字体大小
  /// - Returns: 适配的字体
  static func system(_ size: CGFloat, isBold: Bool = false, isAdapted: Bool = true) -> UIFont {
  
  let finalSize = size
    
  if isBold { return UIFont.boldSystemFont(ofSize: finalSize) }
  
  return UIFont.systemFont(ofSize: finalSize)
  }
  
  /// 自定义字体
  ///
  /// - Parameters:
  ///   - name: 字体名称
  ///   - size: 字体大小
  ///   - isAdapted: 是否为适配模式，默认为是，适配模式会根据屏幕缩放字体大小
  /// - Returns: 字体对象
  static func custom(_ name: String, size: CGFloat, isAdapted: Bool = true) -> UIFont {
    
    let finalSize = size
    return UIFont(name: name, size: finalSize) ?? UIFont.systemFont(ofSize: finalSize)
  }
  
  /*
   PingFang SC - PingFangSC-Medium
   PingFang SC - PingFangSC-Semibold
   PingFang SC - PingFangSC-Light
   PingFang SC - PingFangSC-Ultralight
   PingFang SC - PingFangSC-Regular
   PingFang SC - PingFangSC-Thin
   */
  
}

// MARK: - Utility
public extension Font {
  
  static func allFonts() {
    
    UIFont.familyNames.enumerated().forEach({ (familyOffset, family) in
      
      print("******************************************")
      print("\(familyOffset) - \(family)")
      UIFont.fontNames(forFamilyName: family).enumerated().forEach({ (fontOffset, font) in
        
        print("********** \(fontOffset) - \(font)")
      })
    })
    
  }
  
}





