//
//  KeyboardManager.swift
//  ComponentKit
//
//  Created by William Lee on 2018/7/24.
//  Copyright © 2018 William Lee. All rights reserved.
//

import UIKit

public class KeyboardManager {
  
  private var showHandle: KeyboardHandle?
  private var changeHandle: KeyboardHandle?
  private var hideHandle: KeyboardHandle?
  
  private var origin: CGFloat = 0
  
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
  ///   - view: 将使用该视图作为基准判断
  ///   - container: 将进行调整的视图，如果是UIScrollView，将调整contentOffset.y，其他非滚动视图，默认调整该视图的bounds.origin.y
  func setupAdjust(spacing: CGFloat = 5,
                   for view: UIView,
                   in container: UIView) {
    
    if let scrollView = container as? UIScrollView {
      
      self.setupAdjust(spacing: spacing, for: view, in: scrollView)
      return
    }
    
    self.updateHandles(show: { (frame, duration) in
      
      guard let window = view.window ?? UIApplication.shared.keyWindow else { return }
      guard let rect = view.superview?.convert(view.frame, to: window) else { return }
      
      print("DebugLog", "KeyboardFrame:", frame, "ViewFrame:", view.frame, "Convert:", rect)
      guard frame.minY < rect.maxY else { return }
      let offset = rect.maxY - frame.minY
      
      UIView.animate(withDuration: duration, animations: { container.bounds.origin.y = offset + spacing })
      
    }, hide: { (frame, duration) in
      
      UIView.animate(withDuration: duration, animations: { container.bounds.origin.y = 0 })
      
    })
  }
  
}

// MARK: - Custom Handle
public extension KeyboardManager {
  
  typealias KeyboardHandle = (_ frame: CGRect, _ duration: TimeInterval) -> Void
  
  /// 添加自定义的键盘通知时回调
  ///
  /// - Parameters:
  ///   - showHandle: 键盘显示时回调
  ///   - hideHandle: 键盘隐藏时回调
  ///   - changeHandle: 键盘改变时回调
  func updateHandles(show showHandle: @escaping KeyboardHandle,
                     hide hideHandle: @escaping KeyboardHandle,
                     change changeHandle: KeyboardHandle? = nil) {
    
    self.showHandle = showHandle
    self.hideHandle = hideHandle
    self.changeHandle = changeHandle ?? showHandle
  }
  
}

// MARK: - Notification
private extension KeyboardManager {
  
  @objc func keyboardWillShow(_ notification: Notification) {
    
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidChange), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    
    guard let frame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
    guard let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval else { return }
    
    self.showHandle?(frame, duration)
  }
  
  @objc func keyboardDidChange(_ notification: Notification) {
    
    guard let frame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
    guard let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval else { return }
    
    self.changeHandle?(frame, duration)
  }
  
  @objc func keyboardWillHide(_ notification: Notification) {
    
    NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    
    guard let frame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
    guard let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval else { return }
    
    self.hideHandle?(frame, duration)
  }
  
}

// MARK: - Utility
private extension KeyboardManager {
  
  /// 根据设定的滚动视图来调整偏移量
  ///
  /// - Parameters:
  ///   - spacing: 设置的偏移量
  ///   - view: 需要根据键盘事件调整的视图
  ///   - scrollView: “”
  func setupAdjust(spacing: CGFloat,
                   for view: UIView,
                   in scrollView: UIScrollView) {
    
    self.updateHandles(show: { (frame, duration) in
      
      let point = view.convert(CGPoint(x: view.frame.minX, y: view.frame.maxY), to: scrollView)
      self.origin = scrollView.contentOffset.y
      guard frame.minY < point.y else { return }
      let offset = point.y - frame.minY
      
      UIView.animate(withDuration: duration, animations: {
        
        scrollView.contentOffset.y += (offset + spacing)
      })
      
    }, hide: { [unowned self] (frame, duration) in
      
      UIView.animate(withDuration: duration, animations: {
        
        scrollView.contentOffset.y = self.origin
      })
      
    })
  }
  
}
