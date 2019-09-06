//
//  CollectionCellItem.swift
//  ComponentKit
//
//  Created by William Lee on 27/01/2018.
//  Copyright © 2018 William Lee. All rights reserved.
//

import UIKit

// 遵循该协议后的UICollectionViewCell及其子类，Server才可以更新Cell
public protocol CollectionCellItemUpdatable {
  
  func update(with item: CollectionCellItem)
  
}

public struct CollectionCellItem {
  
  /// 更新Cell的数据
  public var data: Any?
  /// 辅助用数据
  public var accessoryData: Any?
  /// Cell代理
  public weak var delegate: AnyObject?
  
  /// Cell重用符号
  public var reuse: ReuseItem
  
  /// Cell的高度
  public var size: CGSize
  
  // MARK: CellAction
  /// Cell是否可进行选中操作
  public var shouldSelectedHandle: (() -> Bool)?
  /// Cell选中操作
  public var selectedHandle: (() -> Void)?
  /// Cell反选操作
  public var deselectedHandle: (() -> Void)?
  
  public init(_ reuse: ReuseItem,
              data: Any? = nil,
              accessoryData: Any? = nil,
              delegate: AnyObject? = nil,
              size: CGSize = .zero,
              shouldSelect shouldSelectedHandle: (() -> Bool)? = nil,
              selected selectedHandle: (() -> Void)? = nil,
              deselected deselectedHandle: (() -> Void)? = nil) {
    
    self.reuse = reuse
    self.data = data
    self.accessoryData = accessoryData
    self.size = size
    self.delegate = delegate
    self.shouldSelectedHandle = shouldSelectedHandle
    self.selectedHandle = selectedHandle
    self.deselectedHandle = deselectedHandle
  }
  
}
