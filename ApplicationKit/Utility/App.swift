//
//  App.swift
//  ApplicationKit
//
//  Created by William Lee on 2018/6/28.
//  Copyright © 2018 William Lee. All rights reserved.
//

import UIKit
import NetworkKit
import JSONKit

public struct App {
  
  public static var shared: App { return App() }
  
  private init() { }
  
}

// MARK: - Info
public extension App {
  
  /// 应用信息
  var info: [String: Any]? { return Bundle.main.infoDictionary }
  /// 应用名称
  var name: String { return self.info?["CFBundleName"] as? String ?? "- -" }
  /// 应用版本号
  var version: String { return self.info?["CFBundleShortVersionString"] as? String ?? "1.0" }
  /// 应用Build版本
  var build: Int {
    
    let build = self.info?["CFBundleVersion"] as? String ?? "1"
    return Int(build) ?? 1
  }
  
}

// MARK: - AppStore
public extension App {
  
  func fromAppStore(withApp id: String, handle: @escaping (_ info: JSON) -> Void) {
    
    var parameters: [String: Any] = [:]
    parameters["id"] = id
    Network.request(.get, "http://itunes.apple.com/lookup").query(parameters).data({ (data, status) in
      
      guard let data = data else { return }
      var json = JSON(data)
      json = json["results"]
      
      // 调试
      DebugLog(json)
      //let version: String? = json["version"]
      //let url: String? = json["trackViewUrl"]
      DispatchQueue.main.async(execute: {
        
        handle(json)
      })
    })
  }
  
}

// MARK: - StatusBar
public extension App {
  
  /// 状态栏Frame
  var statusBar: CGRect { return UIApplication.shared.statusBarFrame }
  
}

// MARK: - NavigationBar
public extension App {
  
  /// 导航栏Frame
  var navigationBar: CGRect { return CGRect(x: 0, y: self.statusBar.height, width: self.screen.width, height: 44) }
}

// MARK: - Screen
public extension App {
  
  /// 屏幕Size
  var screen: CGSize { return UIScreen.main.bounds.size }
}
