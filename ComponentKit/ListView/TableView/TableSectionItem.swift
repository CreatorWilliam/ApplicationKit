//
//  TableSectionItem.swift
//  ComponentKit
//
//  Created by William Lee on 24/01/2018.
//  Copyright © 2018 William Lee. All rights reserved.
//

import UIKit

// 遵循该协议后的SectionView，Server才可以更新SectionView
public protocol TableSectionItemUpdatable {
  
  func update(with item: TableSectionItem)
}

public struct TableSectionItem {
  
  /// 更新SectionView的数据
  public var data: Any?
  /// 辅助用数据
  public var accessoryData: Any?
  /// 不重用的View
  internal var view: UIView?
  
  /// SectionView代理
  public weak var delegate: AnyObject?
  
  /// SectionView重用符号
  internal var reuseItem: ReuseItem?
  /// 高度
  internal let height: CGFloat
  
  /// 创建动态重用的Section视图
  ///
  /// - Parameters:
  ///   - reuseItem: 重用的Section视图
  ///   - data: Section视图更新的数据，非必须
  ///   - delegate: Section视图的代理，非必须
  ///   - height: Section视图的高度，默认为自适应高度
  public init(_ reuseItem: ReuseItem,
              data: Any? = nil,
              accessoryData: Any? = nil,
              delegate: AnyObject? = nil,
              height: CGFloat = UITableView.automaticDimension) {
    
    self.height = height
    self.reuseItem = reuseItem
    self.delegate = delegate
    self.data = data
    self.accessoryData = accessoryData
  }
  
  /// 创建静态的Section视图
  ///
  /// - Parameters:
  ///   - view: 静态Section视图，若设置为空，Section视图将会为空
  ///   - data: Section视图更新的数据，非必须
  ///   - delegate: Section视图的代理，非必须
  ///   - height: Section视图的高度，默认为无高度，可变高度使用：UITableView.automaticDimension
  public init(_ view: UIView? = nil,
              data: Any? = nil,
              accessoryData: Any? = nil,
              delegate: AnyObject? = nil,
              height: CGFloat = 0.01) {
    
    self.height = height
    self.view = view
    self.delegate = delegate
    self.data = data
    self.accessoryData = accessoryData
  }
  
}
