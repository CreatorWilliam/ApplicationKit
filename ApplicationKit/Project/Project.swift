//
//  Project.swift
//  ApplicationKit
//
//  Created by William Lee on 2018/10/9.
//  Copyright © 2018 William Lee. All rights reserved.
//

import UIKit
import NetworkKit

public class Project {
  
  public static let `default` = Project()
  
  /// 用于检测网路可达性
  private var reachability: Reachability?
  
  private init() { }
}

// MARK: - 项目初始化
public extension Project {
  
  /// 配置UIApplication中window
  var window: UIWindow {
    
    let window = UIWindow(frame: UIScreen.main.bounds)
    window.backgroundColor = .white
    //window.rootViewController = UIViewController()
    window.makeKeyAndVisible()
    return window
  }
  
  /// 设置导航栏默认的样式
  ///
  /// - Parameters:
  ///   - titleColor: 导航栏文字颜色
  ///   - titleFont: 导航栏字体
  ///   - backImageName: 返回按钮的图标
  ///   - backTitle: 返回按钮的标题
  ///   - backgroundColor: 导航栏背景色
  ///   - backgroundImage: 导航栏背景图片
  func setupNavigation(titleColor: UIColor,
                       titleFont: UIFont,
                       backImageName: String,
                       backTitle: String? = nil,
                       backgroundColor: UIColor,
                       backgroundImage: UIImage?) {
    
    let backgroundImage = backgroundImage?.resizableImage(withCapInsets: UIEdgeInsets(top: 1, left: 1, bottom: 1, right: 1), resizingMode: .stretch)
    // Custom Navigation
    NavigationView.defaultTitleColor = titleColor
    NavigationView.defaultTitleFont = titleFont
    NavigationView.defaultBackgroundColor = backgroundColor
    NavigationView.defaultBackgroundImage = backgroundImage
    NavigationView.defaultBackImage = backImageName
    if let title = backTitle { NavigationView.defaultBackTitle = title }
    // NavigationBar
    UINavigationBar.appearance().tintColor = titleColor
    UINavigationBar.appearance().barTintColor = backgroundColor
    UINavigationBar.appearance().setBackgroundImage(backgroundImage, for: .default)
    UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: titleColor, .font: titleFont]
    UINavigationBar.appearance().shadowImage = UIImage()
  }
  
  /// 配置网络请求的主机地址，同时根据网络可达性，发出相应的通知：NetworkKit.Reachability.changedNotification
  ///
  /// - Parameters:
  ///   - isDevelop: 是否是开发环境
  ///   - developHost: 开发环境基地址
  ///   - productHost: 生产环境基地址
  func setupHost(isDevelop: Bool,
                 develop developHost: String,
                 product productHost: String) {
    
    let host = isDevelop ? developHost : productHost
    
    API.host = host
    // 网络可达性监控
    self.reachability = Reachability(host: host)
    self.reachability?.startMonitor()
  }
  
  /// 向指定TabBarController中添加控制器
  ///
  /// - Parameters:
  ///   - viewController: 要添加的控制器
  ///   - title: 标签名称
  ///   - normalImage: 标签图片（未选中）
  ///   - selectedImage: 标签图片（未选中）
  ///   - normalColor: 标签名称颜色（选中）
  ///   - selectedColor: 标签名称颜色（选中）
  ///   - isEmbeddedNavigation: 是否嵌套一个导航栏后再加入UITabBarController
  ///   - tabBarController: 指定的UITabBarController
  func addController(_ viewController: UIViewController,
                     title: String,
                     normalImage: String,
                     selectedImage: String,
                     normalColor: UIColor,
                     selectedColor: UIColor,
                     isEmbeddedNavigation: Bool = true,
                     to tabBarController: UITabBarController) -> Void {
    
    tabBarController.tabBar.isTranslucent = false
    
    viewController.navigationItem.title = title
    viewController.tabBarItem.title = title
    viewController.tabBarItem.setTitleTextAttributes([.foregroundColor: normalColor], for: .normal)
    viewController.tabBarItem.setTitleTextAttributes([.foregroundColor: selectedColor], for: .selected)
    viewController.tabBarItem.image = UIImage(named: normalImage)?.withRenderingMode(.alwaysOriginal)
    viewController.tabBarItem.selectedImage = UIImage(named: selectedImage)?.withRenderingMode(.alwaysOriginal)
    
    if isEmbeddedNavigation == true {
      
      let navigationController = UINavigationController(rootViewController: viewController)
      tabBarController.addChild(navigationController)
      
    } else {
      
      tabBarController.addChild(viewController)
    }
    
  }
  
}
