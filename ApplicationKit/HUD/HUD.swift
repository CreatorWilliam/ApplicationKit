//
//  HUD.swift
//  ComponentKit
//
//  Created by William Lee on 17/03/2018.
//  Copyright © 2018 William Lee. All rights reserved.
//

import UIKit

// MARK: - HUD UIViewController Extension
public extension UIViewController {
  
  private struct HUDExtensionKey {
    
    static var hud: Void?
  }
  
  /// LoadingView
  var hud: HUD {
    
    if let temp = objc_getAssociatedObject(self, &HUDExtensionKey.hud) as? HUD { return temp }
    let temp = HUD(self)
    objc_setAssociatedObject(self, &HUDExtensionKey.hud, temp, .OBJC_ASSOCIATION_RETAIN)
    
    return temp
  }
  
}

public class HUD {
  
  /// 消息视图
  private lazy var messageView = MessageView()
  /// 加载视图
  private lazy var loadingView = LoadingView()
  /// 
  private lazy var activityView = ActivityIndicatorView(frame: .zero)
  private weak var controller: UIViewController?
  
  fileprivate init(_ controller: UIViewController) {
    
    self.controller = controller
  }
  
}

// MARK: - MessageView
public extension HUD {
  
  /// 设置加载视图外观
  ///
  /// - Parameters:
  ///   - foreground: 前景色
  ///   - background: 背景色
  class func messageAppearance(foreground: UIColor = UIColor.white, background: UIColor = UIColor.black.withAlphaComponent(0.6)) {
    
    MessageView.default(foreground: foreground, background: background)
  }
  
  /// 显示消息视图
  ///
  /// - Parameters:
  ///   - title: 消息标题
  ///   - message: 消息内容
  ///   - duration: 持续时间
  ///   - completion: 消息视图隐藏后执行
  func showMessage(title: String? = nil, message: String?, duration: TimeInterval = 1, completion: (() -> Void)? = nil ) {
    
    DispatchQueue.main.async {
      
      self.messageView.frame = self.controller?.view.bounds ?? .zero
      self.messageView.layoutIfNeeded()
      self.controller?.view.addSubview(self.messageView)
      self.messageView.setup(title: title, message: message)
      
      self.controller?.view.bringSubviewToFront(self.messageView)
      self.messageView.show()
      DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
        
        self.controller?.view.sendSubviewToBack(self.messageView)
        self.messageView.hide()
        completion?()
      }
    }
    
  }
  
}

// MARK: - LoadingView
public extension HUD {
  
  /// 设置加载视图外观
  ///
  /// - Parameters:
  ///   - foreground: 前景色
  ///   - background: 背景色
  class func loadingAppearance(foreground: UIColor = UIColor.white, background: UIColor = UIColor.black.withAlphaComponent(0.6)) {
    
    LoadingView.default(foreground: foreground, background: background)
  }
  
  /// 显示加载视图
  ///
  /// - Parameter handle: 加载视图显示后执行
  func showLoading(_ handle: (() -> Void)? = nil) {
    
    DispatchQueue.main.async {
      
      if self.loadingView.superview == nil {
        
        self.controller?.view.addSubview(self.loadingView)
        self.loadingView.layout.add { (make) in
          
          make.top(44).equal(self.controller?.view).safeTop()
          make.bottom().equal(self.controller?.view).safeBottom()
          make.leading().trailing().equal(self.controller?.view)
        }
      }
      
      
      self.loadingView.isHidden = false
      self.controller?.view.bringSubviewToFront(self.loadingView)
      self.loadingView.start()
      handle?()
    }
    
  }
  
  /// 隐藏加载视图
  ///
  /// - Parameter handle: 加载视图隐藏后执行
  func hideLoading(_ handle: (() -> Void)? = nil) {
    
    DispatchQueue.main.async {
      
      self.loadingView.isHidden = true
      self.controller?.view.sendSubviewToBack(self.loadingView)
      self.loadingView.stop()
      handle?()
    }
    
  }
  
}


// MARK: - ActivityIndicatorView
public extension HUD {

  func showActivity(_ handle: (() -> Void)? = nil) {
   
    DispatchQueue.main.async {
      
      if self.activityView.superview == nil {
        
        guard let controller = self.controller else { return }
        self.activityView.layerTintColors = [UIColor(0x23F6EB), UIColor.black, UIColor(0xFF2E56)]
        self.activityView = ActivityIndicatorView.show(in: controller.view)
      }
      self.activityView.startAnimation()
      self.controller?.view.bringSubviewToFront(self.activityView)
      handle?()
    }
  }
  
 
  func hideActivity(_ handle: (() -> Void)? = nil) {
    
    DispatchQueue.main.async {
      
      self.activityView.hide(0.0, compelete: {
        
        handle?()
      })
    }
    
  }
}
