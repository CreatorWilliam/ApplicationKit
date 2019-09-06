//
//  Layoutable.swift
//  LayoutKit
//
//  Created by William Lee on 2018/8/9.
//  Copyright © 2018 William Lee. All rights reserved.
//

import UIKit

public struct Layout<Target> {
  
  let target: Target
  init(_ target: Target) {
    
    self.target = target
  }
  
}

// MARK: - UIView增加创建约束的便捷方法
public extension Layout where Target: UIView {
  
  /// 添加约束,在constraintMake中构造约束
  ///
  /// - Parameter constraintMake: 构造要添加的约束
  func add(_ constraintMake: (ConstraintMaker) -> Void) {

    self.target.translatesAutoresizingMaskIntoConstraints = false
    let maker = ConstraintMaker(target: self.target)
    constraintMake(maker)
    maker.install()
  }
  
  /// 更新约束,在constraintMake中构造约束
  ///
  /// - Parameter constraintMake: 构造更新的约束
  func update(_ constraintMake: (ConstraintMaker) -> Void) {
    
    self.target.translatesAutoresizingMaskIntoConstraints = false
    let maker = ConstraintMaker(target: self.target)
    constraintMake(maker)
    maker.update()
  }
  
  /// 移除约束,在constraintMake中构造约束
  ///
  /// - Parameter constraintMake: 构造要移除的约束
  func remove(_ constraintMake: (ConstraintMaker) -> Void) {
    
    self.target.translatesAutoresizingMaskIntoConstraints = false
    let maker = ConstraintMaker(target: self.target)
    constraintMake(maker)
    maker.uninstall()
  }
}

// MARK: - AutoLayoutCompatible
/// 符合AutoLayoutCompatible的对象能使用便捷方式创建约束
public protocol AutoLayoutCompatible {
  
  associatedtype AutoLayoutCompatibleType
  var layout: AutoLayoutCompatibleType { get }
  
}

// MARK: - AutoLayoutCompatible 为符合该协议的对象提供默认的创建者
public extension AutoLayoutCompatible {
  
  var layout: Layout<Self> { return Layout(self) }
  
}

// MARK: - UIView 遵循 AutoLayoutCompatible
extension UIView: AutoLayoutCompatible { }
