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
  
  /// 不重用的View
  internal var view: UIView?
  
  /// SectionView代理
  public weak var delegate: AnyObject?
  
  /// SectionView重用符号
  internal var reuseItem: ReuseItem?
  
  /// 固定高度
  internal var fixedHeight: CGFloat = 0.01
  /// 可变高度，该数值将会设置为Secion的EstimatedHeight
  internal var flexibleHeight: CGFloat = 0
  
  public init(_ reuseItem: ReuseItem,
              data: Any? = nil,
              delegate: AnyObject? = nil,
              fixed fixedHeight: CGFloat = 0.01,
              flexible flexibleHeight: CGFloat = 0) {
    
    self.fixedHeight = fixedHeight
    self.flexibleHeight = flexibleHeight
    self.reuseItem = reuseItem
    self.delegate = delegate
    self.data = data
  }
  
  public init(_ view: UIView? = nil,
              data: Any? = nil,
              delegate: AnyObject? = nil,
              fixed fixedHeight: CGFloat = 0.01,
              flexible flexibleHeight: CGFloat = 0) {
    
    self.fixedHeight = fixedHeight
    self.flexibleHeight = flexibleHeight
    self.view = view
    self.delegate = delegate
    self.data = data
  }
  
}
