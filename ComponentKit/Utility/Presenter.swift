//
//  Presenter.swift
//  ComponentKit
//
//  Created by William Lee on 2018/8/6.
//  Copyright © 2018 William Lee. All rights reserved.
//

import UIKit

public struct Presenter {
  
  /// 获取当前Present出来的控制器
  public static var currentPresentedController: UIViewController? {
    
    var keyWindow = UIApplication.shared.keyWindow
    if keyWindow?.windowLevel != UIWindow.Level.normal {
      
      for window in UIApplication.shared.windows {
        
        guard window.windowLevel == UIWindow.Level.normal else { continue }
        keyWindow = window
        break
      }
    }
    /// 以当前KeyWindow的根视图控制器当作查找的起始控制器
    return Presenter.queryPresentedViewController(from: keyWindow?.rootViewController)
  }
  
  /// 获取当前Present出来的导航控制器
  public static var currentNavigationController: UINavigationController? {
    
    return Presenter.currentPresentedController?.navigationController
  }
  
  /// Modal展示一个控制器
  ///
  /// - Parameters:
  ///   - presentedViewController: 要显示的控制器
  ///   - animated: 是否有动画，默认有动画
  ///   - completion: 完成展示后执行的闭包
  public static func present(_ presentedViewController: UIViewController, animated: Bool = true, completion: (() -> Void)? = nil) {
    
    Presenter.currentPresentedController?.present(presentedViewController, animated: animated, completion: completion)
  }
  
  /// Modal隐藏一个控制器
  ///
  /// - Parameters:
  ///   - animated: 是否有动画，默认有动画
  ///   - completion: 完成展示后执行的闭包
  public static func dismiss(animated: Bool = true, completion: (() -> Void)? = nil) {
    
    Presenter.currentPresentedController?.dismiss(animated: animated, completion: completion)
  }
  
  /// Push展示一个控制器
  ///
  /// - Parameters:
  ///   - viewController: 要显示的控制器
  ///   - isHideBottomBar: 是否隐藏底部系统Bar，如tabbar等，默认隐藏
  ///   - animated: 是否有动画，默认有动画
  /// - Returns: 若没有导航控制器，调用此方法后，将返回false
  @discardableResult
  public static func push(_ viewController: UIViewController, isHideBottomBar: Bool = true, animated: Bool = true) -> Bool {
    
    guard let navigationController = Presenter.currentNavigationController else { return false }
    viewController.hidesBottomBarWhenPushed = isHideBottomBar
    navigationController.pushViewController(viewController, animated: animated)
    return true
  }
  
  /// 导航栏控制器Pop当前视图
  ///
  /// - Parameter animated: 是否有动画，默认有动画
  /// - Returns: Pop的控制器
  public static func pop(animated: Bool = true) -> UIViewController? {
    
    return Presenter.currentNavigationController?.popViewController(animated: animated)
  }
  
}

// MARK: - Utility
private extension Presenter {
  
  /// 根据给定的起始控制器，沿着Present链进行查找可以进行present操作的控制器
  static func queryPresentedViewController(from startViewController: UIViewController?) -> UIViewController? {
    
    var presentedViewController = startViewController
    
    /// 1、优先进行Present链查找Presented控制器
    while presentedViewController?.presentedViewController != nil {
      
      presentedViewController = presentedViewController?.presentedViewController
    }
    
    /// 2、如果是UITabBarController，则使用当前选中的控制器进一步递归查找
    if let tabbarController = presentedViewController as? UITabBarController {
      
      return self.queryPresentedViewController(from: tabbarController.selectedViewController)
    }
    
    /// 3、如果是UINavigationController，则使用栈顶控制器进一步递归查找
    if let navigationController = presentedViewController as? UINavigationController {
      
      return self.queryPresentedViewController(from: navigationController.topViewController)
    }
    
    return presentedViewController
  }
  
}













