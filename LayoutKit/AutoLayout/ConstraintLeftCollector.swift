//
//  ConstraintLeftCollector.swift
//  LayoutKit
//
//  Created by William Lee on 2018/8/9.
//  Copyright © 2018 William Lee. All rights reserved.
//

import UIKit

public class ConstraintLeftCollector {
  
  /// 左侧约束对象
  private let firstTarget: UIView
  /// 左侧约束相关的约束属性对应的计算常量
  private var firstAttributes: [AttributeItem] = []
  /// 元素间关系
  private var relation: NSLayoutConstraint.Relation = .equal
  /// 右侧约束收集者，用于收集第二元素及第二属性，约束优先级，约束计算系数
  private var rightCollector = ConstraintRightCollector()
  
  
  init(target: UIView ,attribute: NSLayoutConstraint.Attribute, constant: CGFloat) {
    
    self.firstTarget = target
    self.firstAttributes.append(AttributeItem(attribute, constant))
  }
  
}

// MARK: - FirstAttribute
public extension ConstraintLeftCollector {
  
  /// 构造约束，布局属性为高
  @discardableResult
  func height(_ offset: CGFloat = 0) -> Self {
    
    self.firstAttributes.append(AttributeItem(.height, offset))
    return self
  }
  
  /// 构造约束，布局属性为宽
  @discardableResult
  func width(_ offset: CGFloat = 0) -> Self {
    
    self.firstAttributes.append(AttributeItem(.width, offset))
    return self
  }
  
  /// 构造约束，布局属性为顶
  @discardableResult
  func top(_ offset: CGFloat = 0) -> Self {
    
    self.firstAttributes.append(AttributeItem(.top, offset))
    return self
  }
  
  /// 构造约束，布局属性为底
  @discardableResult
  func bottom(_ offset: CGFloat = 0) -> Self {
    
    self.firstAttributes.append(AttributeItem(.bottom, offset))
    return self
  }
  
  /// 构造约束，布局属性为头
  @discardableResult
  func leading(_ offset: CGFloat = 0) -> Self {
    
    self.firstAttributes.append(AttributeItem(.leading, offset))
    return self
  }
  
  /// 构造约束，布局属性为尾
  @discardableResult
  func trailing(_ offset: CGFloat = 0) -> Self {
    
    self.firstAttributes.append(AttributeItem(.trailing, offset))
    return self
  }
  
  /// 构造约束，布局属性为左
  @discardableResult
  func left(_ offset: CGFloat = 0) -> Self {
    
    self.firstAttributes.append(AttributeItem(.left, offset))
    return self
  }
  
  /// 构造约束，布局属性为右
  @discardableResult
  func right(_ offset: CGFloat = 0) -> Self {
    
    self.firstAttributes.append(AttributeItem(.right, offset))
    return self
  }
  
  /// 构造约束，布局属性为中心X
  @discardableResult
  func centerX(_ offset: CGFloat = 0) -> Self {
    
    self.firstAttributes.append(AttributeItem(.centerX, offset))
    return self
  }
  
  /// 构造约束，布局属性为中心Y
  @discardableResult
  func centerY(_ offset: CGFloat = 0) -> Self {
    
    self.firstAttributes.append(AttributeItem(.centerY, offset))
    return self
  }
  
  /// 设置比例
  ///
  /// - Parameter scale: 系数
  /// - Returns: 约束
  @discardableResult
  func multiplier(_ multiplier: CGFloat) -> ConstraintRightCollector {
    
    self.rightCollector.multiplier(multiplier)
    return self.rightCollector
  }
  
  /// 设置优先级
  ///
  /// - Parameter priority: 优先级
  /// - Returns: 约束
  @discardableResult
  func priority(_ priority: UILayoutPriority) -> ConstraintRightCollector {
    
    self.rightCollector.priority(priority)
    return self.rightCollector
  }
  
}

// MARK: - Semantic
public extension ConstraintLeftCollector {
  
  /// 属性关系为相等
  @discardableResult
  func equal(_ target: AnyObject?) -> ConstraintRightCollector {
    
    self.relation = .equal
    self.rightCollector.target = target
    return self.rightCollector
  }
  
  /// 属性关系为不小于
  @discardableResult
  func greaterThanOrEqual(_ target: AnyObject?) -> ConstraintRightCollector {
    
    self.relation = .greaterThanOrEqual
    self.rightCollector.target = target
    return self.rightCollector
  }
  
  /// 属性关系为不大于
  @discardableResult
  func lessThanOrEqual(_ target: AnyObject?) -> ConstraintRightCollector {
    
    self.relation = .lessThanOrEqual
    self.rightCollector.target = target
    return self.rightCollector
  }
  
}

// MARK: - Action
internal extension ConstraintLeftCollector {
  
  func install() {
    
    self.prepare().forEach { $0.install() }
  }
  
  func update() {
    
    self.prepare().forEach { $0.update() }
  }
  
  func uninstall() {
    
    self.prepare().forEach { $0.uninstall() }
  }
  
}

private extension ConstraintLeftCollector {
  
  func prepare() -> [ConstraintItem] {
    
    var constraints: [ConstraintItem] = []
    
    constraints = self.firstAttributes.map { (item) -> ConstraintItem in
      
      // 配置第一元素及属性
      var constraint = ConstraintItem(target: self.firstTarget, attribute: item.attribute, constant: item.offset)
      
      // 配置计算关系
      constraint.relation = self.relation
      
      // 配置第二元素及属性
      constraint.secondTarget = self.rightCollector.target
      if self.rightCollector.target == nil {
        
        self.rightCollector.attribute = .notAnAttribute
      }
      
      // 如果第二元素为空，则第二属性必须为notAnAttribute，否则是错误的约束条件
      if self.rightCollector.target == nil {
        
        constraint.secondAttribute = .notAnAttribute
        
      } else if self.rightCollector.target != nil, self.rightCollector.attribute == .notAnAttribute {
        // 如果第二元素不为空，则第二属性不能为notAnAttribute，否则是错误的约束条件
        
        constraint.secondAttribute = item.attribute
        
      } else {
        
        constraint.secondAttribute = self.rightCollector.attribute
      }

      // 配置计算系数及常量
      constraint.multiplier = self.rightCollector.multiplier
      constraint.constant = item.offset
      
      return constraint
    }
    
    return constraints
  }
  
}
