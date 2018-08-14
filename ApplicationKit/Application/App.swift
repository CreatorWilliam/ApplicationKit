//
//  App.swift
//  ApplicationKit
//
//  Created by William Lee on 2018/6/28.
//  Copyright © 2018 William Lee. All rights reserved.
//

import UIKit

public struct App {
  
  public init() { }
}

// MARK: - Info
public extension App {
  
  /// 应用信息
  public var info: [String: Any]? { return Bundle.main.infoDictionary }
  /// 应用名称
  public var name: String { return self.info?["CFBundleName"] as? String ?? "- -" }
  /// 应用版本号
  public var version: String { return self.info?["CFBundleShortVersionString"] as? String ?? "1.0" }
  /// 应用Build版本
  public var build: String { return self.info?["CFBundleVersion"] as? String ?? "1" }
  
}

// MARK: - StatusBar
public extension App {
  
  /// 状态栏Height
  public var statusBarHeight: CGFloat { return UIApplication.shared.statusBarFrame.height }
  /// 状态栏Widht
  public var statusBarWidth: CGFloat { return UIApplication.shared.statusBarFrame.width }

}

// MARK: - NavigationBar
public extension App {
  
  /// 导航栏Height
  public var navigationBarHeight: CGFloat { return 44 }
  /// 导航栏Width
  public var navigationBarWidth: CGFloat { return self.screenWidht }
}

// MARK: - Screen
public extension App {
  
  /// 屏幕size
  public var screenSize: CGSize { return UIScreen.main.bounds.size }
  /// 屏幕Width
  public var screenWidht: CGFloat { return self.screenSize.width }
  /// 屏幕Hidht
  public var screenHeight: CGFloat { return self.screenSize.height }
}









