//
//  ConstraintMaker.swift
//  LayoutKit
//
//  Created by William Lee on 2018/8/9.
//  Copyright © 2018 William Lee. All rights reserved.
//

import UIKit

public class ConstraintMaker {
  
  /// 约束的第一目标
  private let target: UIView
  /// 包含约束元素的收集者
  private var collectors: [ConstraintLeftCollector] = []
  
  internal init(target: UIView) {
    
    self.target = target
  }
  
}

// MARK: - Statement
public extension ConstraintMaker {
  
  /// 构造约束，布局属性为高
  @discardableResult
  func height(_ offset: CGFloat = 0) -> ConstraintLeftCollector {
    
    let collector = ConstraintLeftCollector(target: self.target, attribute: .height, constant: offset)
    self.collectors.append(collector)
    return collector
  }
  
  /// 构造约束，布局属性为宽
  @discardableResult
  func width(_ offset: CGFloat = 0) -> ConstraintLeftCollector {
    
    let collector = ConstraintLeftCollector(target: self.target, attribute: .width, constant: offset)
    self.collectors.append(collector)
    return collector
  }
  
  /// 构造约束，布局属性为顶
  func top(_ offset: CGFloat = 0) -> ConstraintLeftCollector {
    
    let collector = ConstraintLeftCollector(target: self.target, attribute: .top, constant: offset)
    self.collectors.append(collector)
    return collector
  }
  
  /// 构造约束，布局属性为底
  func bottom(_ offset: CGFloat = 0) -> ConstraintLeftCollector {
    
    let collector = ConstraintLeftCollector(target: target, attribute: .bottom, constant: offset)
    self.collectors.append(collector)
    return collector
  }
  
  /// 构造约束，布局属性为左
  func left(_ offset: CGFloat = 0) -> ConstraintLeftCollector {
    
    let collector = ConstraintLeftCollector(target: target, attribute: .left, constant: offset)
    self.collectors.append(collector)
    return collector
  }
  
  /// 构造约束，布局属性为右
  func right(_ offset: CGFloat = 0) -> ConstraintLeftCollector {
    
    let collector = ConstraintLeftCollector(target: target, attribute: .right, constant: offset)
    self.collectors.append(collector)
    return collector
  }
  
  /// 构造约束，布局属性为头
  func leading(_ offset: CGFloat = 0) -> ConstraintLeftCollector {
    
    let collector = ConstraintLeftCollector(target: target, attribute: .leading, constant: offset)
    self.collectors.append(collector)
    return collector
  }
  
  /// 构造约束，布局属性为尾
  func trailing(_ offset: CGFloat = 0) -> ConstraintLeftCollector {
    
    let collector = ConstraintLeftCollector(target: target, attribute: .trailing, constant: offset)
    self.collectors.append(collector)
    return collector
  }
  
  /// 构造约束，布局属性为中心X
  func centerX(_ offset: CGFloat = 0) -> ConstraintLeftCollector {
    
    let collector = ConstraintLeftCollector(target: target, attribute: .centerX, constant: offset)
    self.collectors.append(collector)
    return collector
  }
  
  /// 构造约束，布局属性为中心Y
  func centerY(_ offset: CGFloat = 0) -> ConstraintLeftCollector {
    
    let collector = ConstraintLeftCollector(target: target, attribute: .centerY, constant: offset)
    self.collectors.append(collector)
    return collector
  }
  
  /// 创建抗压缩约束
  ///
  /// - Parameters:
  ///   - axis: 抗压缩的方向
  ///   - priority: 约束等级
  func compression(axis: NSLayoutConstraint.Axis,
                          priority: UILayoutPriority = UILayoutPriority.required) -> Void{
    
    self.target.setContentCompressionResistancePriority(priority, for: axis)
  }
  
  /// 创建抗拉伸约束
  ///
  /// - Parameters:
  ///   - axis: 抗拉伸的方向
  ///   - priority: 约束等级
  func hugging(axis: NSLayoutConstraint.Axis,
                      priority: UILayoutPriority = UILayoutPriority.required) -> Void {
    
    self.target.setContentHuggingPriority(priority, for: axis)
  }
  
}


// MARK: - Action
internal extension ConstraintMaker {
  
  /// 装载构造的约束
  func install() {
    
    self.collectors.forEach { $0.install() }
    
  }
  
  /// 更新构造的约束
  func update() {
    
    self.collectors.forEach { $0.update() }
    
  }
  
  /// 卸载构造的约束
  func uninstall() {
    
    self.collectors.forEach { $0.uninstall() }
    
  }
  
}
