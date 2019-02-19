//
//  FormInputItem.swift
//  ApplicationKit
//
//  Created by William Lee on 2019/1/23.
//  Copyright © 2019 William. All rights reserved.
//

import UIKit

public class FormInputItem {
  
  /// 表单选项名称
  public let title: String
  /// 占位文字
  public var placeholder: String?
  /// 输入的值
  public var value: String?
  /// 是否可以编辑
  public var isEditable: Bool = true
  /// 是否是必填
  public var isRequired: Bool
  /// 用于保存提交表单时的字段名称
  //public var parameterName: String? = nil
  /// 正则校验
  public var regular: Regular.Kind?
  
  public init(title: String, isRequired: Bool = false) {
    
    self.title = title
    self.isRequired = isRequired
  }
  
}

// MARK: - Public
public extension FormInputItem {
  
  public var keyboardType: UIKeyboardType {
    
    guard let regular = self.regular else { return .default }
    switch regular {
    case .account:
      
      if #available(iOS 10.0, *) {
        return .asciiCapableNumberPad
      } else {
        return .asciiCapable
      }
      
    case .mobil: return .numberPad
      
    case .email: return .emailAddress
      
    default: return .default
    }
  }
  
  public func verify(hasMessage: Bool = false) -> Bool {
    
    guard let regular = self.regular else { return true }
    
    return self.value?.check(regular) ?? false
  }
  
}
