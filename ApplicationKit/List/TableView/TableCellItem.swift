//
//  TableCellItem.swift
//  ComponentKit
//
//  Created by William Lee on 20/01/2018.
//  Copyright © 2018 William Lee. All rights reserved.
//

import UIKit

// 遵循该协议后的UITableViewCell及其子类，Server才可以更新Cell
public protocol TableCellItemUpdatable {
  
  //associatedtype DataSource
  //func update(with item: TableCellItem<DataSource>)
  func update(with item: TableCellItem)
}

public struct TableCellItem/*<DataSource>*/ {
  
  /// 更新Cell的数据
  public var data: Any?
  
  /// 辅助用数据
  public var accessoryData: Any?
  
  /// Cell代理
  public weak var delegate: AnyObject?
  
  /// 动态Cell
  internal var reuseItem: ReuseItem?
  /// 静态Cell
  internal var staticCell: UITableViewCell?
  
  // MARK: CellStyle
  /// UITableViewCellAccessoryType
  internal var accessoryType: UITableViewCell.AccessoryType
  /// Cell的分割线间距
  internal var seperatorInsets: UIEdgeInsets?
  /// Cell的高度
  internal var height: CGFloat
  
  // MARK: CellAction
  /// Cell选中操作
  internal var selectedHandle: (() -> Void)?
  /// Cell反选操作
  internal var deselectedHandle: (() -> Void)?
  /// 删除操作
  internal var deleteHandle: (() -> Void)?
  
  /// 创建Cell
  ///
  /// - Parameters:
  ///   - reuse: 重用Cell
  ///   - staticCell: 静态Cell,优先使用静态Cell，如果有的话
  ///   - data: 填充Cell的数据
  ///   - accessoryData: 补充数据
  ///   - delegate: 代理
  ///   - accessoryType: 样式
  ///   - insets: Seperator的间距
  ///   - height: 行高
  ///   - selectedHandle: 选中操作
  ///   - deselectedHandle: 反选操作
  public init(_ reuse: ReuseItem,
              data: Any? = nil,
              accessoryData: Any? = nil,
              delegate: AnyObject? = nil,
              accessoryType: UITableViewCell.AccessoryType = .none,
              seperatorInsets insets: UIEdgeInsets? = nil,
              height: CGFloat = UITableView.automaticDimension,
              selected selectedHandle: (() -> Void)? = nil,
              deselected deselectedHandle: (() -> Void)? = nil,
              deleteHandle: (() -> Void)? = nil) {
    
    self.reuseItem = reuse
    self.data = data
    self.accessoryData = accessoryData
    self.delegate = delegate
    self.accessoryType = accessoryType
    self.seperatorInsets = insets
    self.height = height
    self.selectedHandle = selectedHandle
    self.deselectedHandle = deselectedHandle
    self.deleteHandle = deleteHandle
  }
  
  /// 创建Cell
  ///
  /// - Parameters:
  ///   - staticCell: 静态Cell,优先使用静态Cell，如果有的话
  ///   - data: 填充Cell的数据
  ///   - accessoryData: 补充数据
  ///   - delegate: 代理
  ///   - accessoryType: 样式
  ///   - insets: Seperator的间距
  ///   - height: 行高
  ///   - selectedHandle: 选中操作
  ///   - deselectedHandle: 反选操作
  public init(_ staticCell: UITableViewCell,
              data: Any? = nil,
              accessoryData: Any? = nil,
              delegate: AnyObject? = nil,
              accessoryType: UITableViewCell.AccessoryType = .none,
              seperatorInsets insets: UIEdgeInsets = UIEdgeInsets(top: 0, left: 0.01, bottom: 0, right: 0.01),
              height: CGFloat = UITableView.automaticDimension,
              selected selectedHandle: (() -> Void)? = nil,
              deselected deselectedHandle: (() -> Void)? = nil,
              deleteHandle: (() -> Void)? = nil) {
    
    self.staticCell = staticCell
    self.data = data
    self.accessoryData = accessoryData
    self.delegate = delegate
    self.accessoryType = accessoryType
    self.seperatorInsets = insets
    self.height = height
    self.selectedHandle = selectedHandle
    self.deselectedHandle = deselectedHandle
    self.deleteHandle = deleteHandle
  }
  
}
