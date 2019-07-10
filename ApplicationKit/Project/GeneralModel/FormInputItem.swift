//
//  FormInputItem.swift
//  ApplicationKit
//
//  Created by William Lee on 2019/1/23.
//  Copyright © 2019 William. All rights reserved.
//

import UIKit

@available(iOS, deprecated: 9.0, message: "请使用MenuItem代替")
public class FormInputItem {
  
  /// 表单选项名称
  public var title: String?
  /// 占位文字
  public var placeholder: String?
  /// 用于保存界面显示的值
  public var visibleValue: String? {
    /// 同步给parameter
    didSet {
      /// 如果置空，或者是可编辑录入的，同步传给parameter
      if self.visibleValue == nil || self.isEditable == true {
        
        self.parameter = self.visibleValue
      }
      
    }
  }
  
  /// 用于保存表单提交时的参数值，对于非编辑录入的类型，自行维护值，但是visibleValue置空，本值依然也会置空
  public var parameter: Any?
  
  /// 用于保存附加数据
  public var accessoryData: Any?
  
  /// 存储代理属性
  public weak var delegate: AnyObject?
  
  /// 是否是必填,仅仅是一个标志，不参与内部验证
  public var isRequired: Bool
  
  /// 是否可以编辑
  public var isEditable: Bool = true
  /// 正则校验，仅对可编辑的项目进行校验,对于非编辑选项，设置了也会置空
  public var regular: Regular.Kind? { didSet { if self.isEditable == false { self.regular = nil } } }
  /// 用于保存输入时键盘样式
  public var keyboardType: UIKeyboardType = .default
  
  public init(title: String? = nil,
              isRequired: Bool = false) {
    
    self.title = title
    self.isRequired = isRequired
  }
  
}

// MARK: - Public
public extension FormInputItem {
  
  func clear() {
    
    self.visibleValue = nil
  }
  
  /// 验证是否录入了数据，对于设置了
  ///
  /// - Parameter hasMessage: 是否显示提示（待完善），默认不显示
  /// - Returns: 验证结果：true为通过，false为不通过
  func verify(hasMessage: Bool = false) -> Bool {
    
    /// 非编辑选项，则只验证是否选中了选项
    guard self.isEditable == true else { return self.parameter != nil }
    
    /// 未设置正则验证的编辑选项，则只验证是否录入
    guard let regular = self.regular else { return self.parameter != nil }
    
    /// 设置了正则验证的编辑选项，则进行验证，是否满足符合录入要求
    return (self.parameter as? String)?.check(regular) ?? false
  }
  
}
