//
//  ConstraintItem.swift
//  LayoutKit
//
//  Created by William Lee on 2018/8/9.
//  Copyright © 2018 William Lee. All rights reserved.
//

import UIKit

struct ConstraintItem {
  
  let firstTarget: UIView
  let firstAttribute: NSLayoutConstraint.Attribute
  var relation: NSLayoutConstraint.Relation = NSLayoutConstraint.Relation.equal
  var secondTarget: AnyObject? = nil
  var secondAttribute: NSLayoutConstraint.Attribute = .notAnAttribute
  var multiplier: CGFloat = 1
  var constant: CGFloat = 0
  var priority: UILayoutPriority = UILayoutPriority.required
  
  var isSafeArea: Bool = true
  
  init(target: UIView ,attribute: NSLayoutConstraint.Attribute, constant: CGFloat) {
    
    self.firstTarget = target
    self.firstAttribute = attribute
    self.constant = constant
    
  }
  
}

// MARK: - Action
internal extension ConstraintItem {
  
  /// 装载约束
  func install() {
    
    NSLayoutConstraint(item: self.firstTarget,
                       attribute: self.firstAttribute,
                       relatedBy: self.relation,
                       toItem: self.secondTarget,
                       attribute: self.secondAttribute,
                       multiplier: self.multiplier,
                       constant: self.constant).isActive = true
    
  }
  
  /// 更新约束
  func update() {
    
    var constraints: [NSLayoutConstraint] = self.firstTarget.constraints

    if let hostConstraints = self.firstTarget.superview?.constraints {

      constraints += hostConstraints
    }
    
    for constraint in constraints {
      
      guard self.isSimilar(constraint) else { continue }
      constraint.constant = self.constant
      constraint.isActive = true
      return
    }
    
    self.install()
  }
  
  /// 卸载约束
  func uninstall() {
    
    var constraints: [NSLayoutConstraint] = self.firstTarget.constraints
    if let hostConstraints = self.firstTarget.superview?.constraints {

      constraints += hostConstraints
    }
 
    for constraint in constraints {
  
      guard self.isSimilar(constraint) else { continue }
      constraint.isActive = false
      return
    }
    
  }
  
}

// MARK: - Utitilty
private extension ConstraintItem {
  
  /// 判断两约束是否类似
  ///
  /// - Parameter compared: 比较的另外一个约束
  /// - Returns: true，类似，false：不同
  private func isSimilar(_ compared: NSLayoutConstraint) -> Bool {
    
    if self.firstTarget !== compared.firstItem { return false }
    if self.firstAttribute != compared.firstAttribute { return false }
    if self.relation != compared.relation { return false }
    if self.multiplier != compared.multiplier { return false }
    if self.secondTarget !== compared.secondItem { return false }
    if self.secondAttribute != compared.secondAttribute { return false }
    if self.priority != compared.priority { return false }
    
    return true
  }
  
}
