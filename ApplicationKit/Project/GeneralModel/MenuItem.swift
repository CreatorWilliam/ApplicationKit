//
//  MenuItem.swift
//  ApplicationKit
//
//  Created by William Lee on 2019/7/6.
//  Copyright © 2019 William Lee. All rights reserved.
//

import UIKit

public class MenuItem {
  
  /// 数据源模式
  public var mode: DataSourceMode = .none
  
  /// 表单选项名称
  public var title: String?
  /// 占位文字
  public var placeholder: String?
  /// 是否为必要的,仅仅是一个标志，不参与内部验证
  public var isRequired: Bool = false
  /// 界面显示的值
  /// 输入模式下，显示的为inputValue
  /// 选择模式下，保存selectionDatas中selectedIndex对应数据的title
  public var visibleValue: String?
  /// 保存提交的参数
  /// 输入模式下，保存inputValue
  /// 选择模式下，保存selectionDatas中selectedIndex对应数据的parameter
  public private(set) var parameter: Any?
  /// 用于传递代理
  public weak var delegate: AnyObject?
  /// 用于传递附加的数据
  public var accessoryData: Any?
  
  /// 父节点
  public weak var fatherItem: MenuItem?
  /// 子节点
  public var childrenItem: MenuItem? { didSet { self.childrenItem?.fatherItem = self } }
  
  /// 用于保存数据变更后执行的一个回调，注意弱引用
  public var changedAction: (() -> Void)?
  
  // MARK: - 输入模式下使用的相关参数
  /// 输入模式下，数据会同步给visibleValue和parameter，否则无效
  public var inputValue: String? {
    didSet {
      /// 确保只有在输入模式下有效
      guard mode == .input else {
        inputValue = nil
        return
      }
      /// 保证只有设置不同的新值，才会继续执行
      if inputValue == oldValue { return }
      
      defer {
        changedAction?()
      }
      
      /// 验证是否有输入的值，否则同步置空
      guard let value = inputValue else {
        visibleValue = nil
        parameter = nil
        return
      }
      /// 确保输入的值为非空的字符串
      guard value.isEmpty == false else {
        visibleValue = nil
        parameter = nil
        return
      }
      visibleValue = value
      parameter = value
      
    }
  }
  /// 输入模式下，用于正则校验，可直接调用verify来验证输入的内容是否符合规则
  public var regular: String?
  /// 输入模式下，唤起键盘时的样式
  public var keyboardType: UIKeyboardType = .default
  /// 输入模式下，返回true，其他模式为false
  public var isEditable: Bool {
    switch mode {
    case .input: return true
    default: return false
    }
  }
  
  // MARK: - 选择模式下使用的相关参数
  
  /// 选择模式下，保存选中的索引, 会同步数据给visibleValue和parameter，其他模式下无效
  public var selectedIndex: Int? {
    didSet {
      /// 保证只有在选择模式下才有效
      guard mode == .selection else {
        selectedIndex = nil
        return
      }
      
      /// 保证只有设置不同的新值，才会继续执行
      if selectedIndex == oldValue { return }
      
      defer {
        changedAction?()
      }
      
      /// 验证是否有选择的值，否则同步置空
      guard let index = selectedIndex else {
        visibleValue = nil
        parameter = nil
        return
      }
      /// 确保设置正确的索引
      guard index < 0 && index > (selectionDatas.count) else {
        visibleValue = nil
        parameter = nil
        return
      }
      /// 设置数据
      visibleValue = selectionDatas[index].title
      parameter = selectionDatas[index].parameter
    }
  }
  /// 选择模式下，用于保存选项数据源，其他模式下无效
  public var selectionDatas: [MenuSelectionDataItem] = [] {
    didSet {
      if mode != .selection { selectionDatas = [] }
    }
  }
  
  // MARK: - 构造函数
  
  /// 默认的构造函数
  ///
  /// - Parameters:
  ///   - style: 数据源模式
  ///   - title: 标题
  ///   - isRequired: 是否为必选
  public init(mode: DataSourceMode = .none,
              title: String? = nil,
              isRequired: Bool = false) {
    
    self.mode = mode
    self.title = title
    self.isRequired = isRequired
  }
  
}

// MARK: - DataSourceMode
public extension MenuItem {
  
  /// 数据源样式
  enum DataSourceMode {
    /// 无
    case none
    /// 输入
    case input
    /// 选择
    case selection
  }
  
}

// MARK: - Public
public extension MenuItem {
  
  func clear() {
    
    visibleValue = nil
    parameter = nil
    
    selectedIndex = nil
    selectionDatas.removeAll()
  }
  
  /// 验证是否录入了数据，对于设置了
  ///
  /// - Parameter hasMessage: 是否显示提示（待完善），默认不显示
  /// - Returns: 验证结果：true为通过，false为不通过
  func verify(hasMessage: Bool = false) -> Bool {
    
    /// 非编辑选项，则只验证是否选中了选项
    guard self.isEditable == true else { return parameter != nil }
    
    /// 未设置正则验证的编辑选项，则只验证是否录入
    guard let regular = regular else { return parameter != nil }
    
    /// 设置了正则验证的编辑选项，则进行验证，是否满足符合录入要求
    return NSPredicate(format: "SELF MATCHES %@", regular).evaluate(with: parameter as? String)
  }
  
}
