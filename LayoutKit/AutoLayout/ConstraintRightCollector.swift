//
//  ConstraintRightCollector.swift
//  LayoutKit
//
//  Created by William Lee on 2018/8/9.
//  Copyright © 2018 William Lee. All rights reserved.
//

import UIKit

public class ConstraintRightCollector {
  
  /// 约束对象
  var target: AnyObject?
  /// 约束属性
  var attribute: NSLayoutConstraint.Attribute = .notAnAttribute
  
  /// 约束计算系数
  var multiplier: CGFloat = 1
  
  /// 约束优先级
  var priority: UILayoutPriority = .required
  
  
  
  init(target: AnyObject? = nil) {
    
    self.target = target
  }
  
}

// MARK: - FirstAttribute
public extension ConstraintRightCollector {
  
  /// 顶部安全区属性
  @discardableResult
  func safeTop() -> Self {
    
    if #available(iOS 11.0, *), let view = self.target as? UIView {
      
      self.target = view.safeAreaLayoutGuide
      self.attribute = .top
      
    } else if #available(iOS 11.0, *), let controller = self.target as? UIViewController {
      
      self.target = controller.view.safeAreaLayoutGuide
      self.attribute = .top
      
    } else if let controller = self.target as? UIViewController {
      
      self.target = controller.topLayoutGuide
      self.attribute = .bottom
      
    } else if let view = self.target as? UIView {
      
      if view.viewController()?.topLayoutGuide != nil {
        
        self.target = view.viewController()?.topLayoutGuide
        self.attribute = .bottom
        
      } else {
        
        self.attribute = .top
      }
      
    } else {
      
      self.attribute = .top
    }
    
    return self
  }
  
  /// 底部安全区属性
  @discardableResult
  func safeBottom() -> Self {
    
    if #available(iOS 11.0, *), let view = self.target as? UIView {
      
      self.target = view.safeAreaLayoutGuide
      self.attribute = .bottom
      
    } else if #available(iOS 11.0, *), let controller = self.target as? UIViewController {
      
      self.target = controller.view.safeAreaLayoutGuide
      self.attribute = .bottom
      
    } else if let controller = self.target as? UIViewController {
      
      self.target = controller.bottomLayoutGuide
      self.attribute = .top
      
    } else if let view = self.target as? UIView {
      
      if view.viewController()?.bottomLayoutGuide != nil {
        
        self.target = view.viewController()?.bottomLayoutGuide
        self.attribute = .top
        
      } else {
        
        self.attribute = .bottom
      }
      
    } else {
      
      self.attribute = .bottom
    }
    
    return self
  }
  
  /// Leading安全区属性
  @discardableResult
  func safeLeading() -> Self {
    
    if #available(iOS 11.0, *), let view = self.target as? UIView {
      
      self.target = view.safeAreaLayoutGuide
    }
    
    self.attribute = .leading
    return self
  }
  
  /// Trailing安全区属性
  @discardableResult
  func safeTrailing() -> Self {
    
    if #available(iOS 11.0, *), let view = self.target as? UIView {
      
      self.target = view.safeAreaLayoutGuide
    }
    
    self.attribute = .trailing
    return self
  }
  
  /// 高度属性
  @discardableResult
  func height() -> Self {
    
    self.attribute = .height
    return self
  }
  
  /// 宽度属性
  @discardableResult
  func width() -> Self {
    
    self.attribute = .width
    return self
  }
  
  /// 顶部属性
  @discardableResult
  func top() -> Self {
    
    self.attribute = .top
    return self
  }
  
  /// 底部属性
  @discardableResult
  func bottom() -> Self {
    
    self.attribute = .bottom
    return self
  }
  
  /// leading属性
  @discardableResult
  func leading() -> Self {
    
    self.attribute = .leading
    return self
  }
  
  /// trailing属性
  @discardableResult
  func trailing() -> Self {
    
    self.attribute = .trailing
    return self
  }
  
  /// left属性
  @discardableResult
  func left() -> Self {
    
    self.attribute = .left
    return self
  }
  
  /// right属性
  @discardableResult
  func right() -> Self {
    
    self.attribute = .right
    return self
  }
  
  /// 中心X属性
  @discardableResult
  func centerX() -> Self {
    
    self.attribute = .centerX
    return self
  }
  
  /// 中心Y属性
  @discardableResult
  func centerY() -> Self {
    
    self.attribute = .centerY
    return self
  }
  
  /// 计算系数
  @discardableResult
  func multiplier(_ multiplier: CGFloat) -> Self {
    
    self.multiplier = multiplier
    return self
  }
  
  /// 优先级
  @discardableResult
  func priority(_ priority: UILayoutPriority) -> Self {
    
    self.priority = priority
    return self
  }
  
}

// MARK: - Utility
fileprivate extension UIView {
  
  func viewController() -> UIViewController? {
    
    var nextResponder: UIResponder? = self
    
    repeat {
      
      nextResponder = nextResponder?.next
      
      if let viewController = nextResponder as? UIViewController { return viewController }
      
    } while nextResponder != nil
    
    return nil
  }
  
}
