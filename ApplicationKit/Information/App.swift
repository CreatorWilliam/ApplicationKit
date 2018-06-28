//
//  App.swift
//  ApplicationKit
//
//  Created by William Lee on 2018/6/28.
//  Copyright © 2018 William Lee. All rights reserved.
//

import Foundation

public struct App {
  
  /// 应用信息
  public var info: [String: Any]? { return Bundle.main.infoDictionary }
  /// 应用名称
  public var name: String { return self.info?["CFBundleName"] as? String ?? "- -" }
  /// 应用版本号
  public var version: String { return self.info?["CFBundleShortVersionString"] as? String ?? "1.0" }
  /// 应用Build版本
  public var build: String { return self.info?["CFBundleVersion"] as? String ?? "1" }
  
  public init() { }
}
