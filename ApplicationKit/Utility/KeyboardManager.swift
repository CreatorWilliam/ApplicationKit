//
//  KeyboardManager.swift
//  ComponentKit
//
//  Created by William Lee on 2018/7/24.
//  Copyright © 2018 William Lee. All rights reserved.
//

import UIKit

public class KeyboardManager {
  
  /// 参考视图，默认为当前第一响应者
  public weak var referenceView: UIView?
  /// 执行调整的视图
  public weak var adjustedView: UIView?
  /// 键盘上边缘与参考视图下边缘的间距
  public var spacing: CGFloat = 5
  
  /// 用于保存调整前的原点
  private var origin: CGFloat = 0
  /// 用于记录是否该更新origin的数值
  private var shouldUpdateOrigin: Bool = true
  
  public init() {
    
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
  }
  
  deinit {
    
    NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
    NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
  }
  
}

// MARK: - Convince
public extension KeyboardManager {
  
  /// 配置一个默认的偏移量
  ///
  /// - Parameters:
  ///   - spacing: 指定视图距离键盘顶部的距离
  ///   - view: 将使用该视图作为基准判断,不设置则查找当前第一响应者调整
  ///   - container: 将进行调整的视图，如果是UIScrollView，将调整contentOffset.y，其他非滚动视图，默认调整该视图的bounds.origin.y
  func setupAdjust(spacing: CGFloat = 5,
                   for view: UIView? = nil,
                   in container: UIView) {
    self.spacing = 5
    self.referenceView = view
    self.adjustedView = container
  }
  
}

// MARK: - Notification
private extension KeyboardManager {
  
  @objc func keyboardWillShow(_ notification: Notification) {
    
    /// 获取必要的视图
    guard let referenceView: UIView = self.referenceView ?? queryTextInputView() else { return }
    guard let adjustContainer = adjustedView else { return }
    
    /// 注册键盘变更的通知
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidChange), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    
    /// 获取键盘相关的参数
    guard let frame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
    guard let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval else { return }
    
    /// 获取参考视图在当前视窗上的位置，以此计算偏移量
    guard let window = referenceView.window ?? UIApplication.shared.keyWindow else { return }
    guard let rect = referenceView.superview?.convert(referenceView.frame, to: window) else { return }
    
    /// 保存偏移的状态
    if shouldUpdateOrigin == true {
      
      shouldUpdateOrigin = false
      if let scrollView = adjustContainer as? UIScrollView {
        
        origin = scrollView.contentOffset.y
        
      } else {
        
        origin = adjustContainer.bounds.origin.y
      }
      
    }
    
    /// 计算偏移量
    guard frame.minY < rect.maxY else { return }
    let offset = rect.maxY - frame.minY
    
    /// 进入编辑后的界面偏移状态，并执行偏移动画
    if let scrollView = adjustContainer as? UIScrollView {
      
      UIView.animate(withDuration: duration, animations: { scrollView.contentOffset.y += (offset + self.spacing) })
      
    } else {
      
      UIView.animate(withDuration: duration, animations: { adjustContainer.bounds.origin.y = offset + self.spacing })
    }
  }
  
  @objc func keyboardDidChange(_ notification: Notification) {
    
    /// 获取必要的视图
    guard let referenceView: UIView = self.referenceView ?? queryTextInputView() else { return }
    guard let adjustContainer = adjustedView else { return }
    
    /// 获取键盘相关的参数
    guard let frame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
    guard let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval else { return }
    
    /// 获取参考视图在当前视窗上的位置，以此计算偏移量
    guard let window = referenceView.window ?? UIApplication.shared.keyWindow else { return }
    guard let rect = referenceView.superview?.convert(referenceView.frame, to: window) else { return }
    
    /// 计算偏移量
    guard frame.minY < rect.maxY else { return }
    let offset = rect.maxY - frame.minY
    
    /// 执行偏移动画
    if let scrollView = adjustContainer as? UIScrollView {
      
      UIView.animate(withDuration: duration, animations: { scrollView.contentOffset.y += (offset + self.spacing) })
      
    } else {
      
      UIView.animate(withDuration: duration, animations: { adjustContainer.bounds.origin.y = offset + self.spacing })
    }
  }
  
  @objc func keyboardWillHide(_ notification: Notification) {
    
    /// 获取必要的视图
    guard let adjustContainer = adjustedView else { return }
    
    /// 移除键盘变化通知
    NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    
    /// 获取键盘相关的参数
    guard let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval else { return }
    
    /// 恢复到编辑前时的界面偏移状态，执行动画
    if let scrollView = adjustContainer as? UIScrollView {
      
      UIView.animate(withDuration: duration, animations: {
        
        scrollView.contentOffset.y = self.origin
        
      }, completion: { (_) in
        
        self.shouldUpdateOrigin = true
      })
      UIView.animate(withDuration: duration, animations: {  })
      
    } else {
      
      UIView.animate(withDuration: duration, animations: {
        
        adjustContainer.bounds.origin.y = self.origin
        
      }, completion: { (_) in
        
        self.shouldUpdateOrigin = true
      })
    }
    
  }
  
}

// MARK: - Utility
private extension KeyboardManager {
  
  func queryTextInputView() -> UIView? {
    
    return UIApplication.shared.keyWindow?.queryFirstResponder()
  }
  
}

fileprivate extension UIView {
  
  func queryFirstResponder() -> UIView? {
    
    if isFirstResponder == true { return self }
    for subview in subviews {
      
      guard let firstResponder = subview.queryFirstResponder() else { continue }
      return firstResponder
    }
    return nil
  }
}
