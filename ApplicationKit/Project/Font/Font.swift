//
//  Font.swift
//  ComponentKit
//
//  Created by William Lee on 07/02/2018.
//  Copyright © 2018 William Lee. All rights reserved.
//

import UIKit

public struct Font {
  
}

public extension Font {
  
  /// 系统字体
  ///
  /// - Parameters:
  ///   - size: 设计稿中字体大小
  ///   - isBold: 是否为粗体，默认为否
  /// - Returns: 字体对象
  static func system(_ size: CGFloat, isBold: Bool = false) -> UIFont {
    
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

// MARK: - PingFangSC
public extension Font {
  
  static func pingFangSCHeavy(_ size: CGFloat) -> UIFont { return Font.custom("PingFangSC-Heavy", size: size) }
  
  static func pingFangSCSemibold(_ size: CGFloat) -> UIFont { return Font.custom("PingFangSC-Semibold", size: size) }
  
  static func pingFangSCMedium(_ size: CGFloat) -> UIFont { return Font.custom("PingFangSC-Medium", size: size) }
  
  static func pingFangSCRegular(_ size: CGFloat) -> UIFont { return Font.custom("PingFangSC-Regular", size: size) }
  
  static func pingFangSCThin(_ size: CGFloat) -> UIFont { return Font.custom("PingFangSC-Thin", size: size) }
  
  static func pingFangSCLight(_ size: CGFloat) -> UIFont { return Font.custom("PingFangSC-Light", size: size) }
  
  static func pingFangSCUltralight(_ size: CGFloat) -> UIFont { return Font.custom("PingFangSC-Ultralight", size: size) }
  
}
