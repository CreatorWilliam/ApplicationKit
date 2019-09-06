//
//  CollectionSectionItem.swift
//  ComponentKit
//
//  Created by William Lee on 2018/10/17.
//  Copyright © 2018 William Lee. All rights reserved.
//

import UIKit

// 遵循该协议后的SectionView，Server才可以更新SectionView
public protocol CollectionSectionItemUpdatable {
  
  func update(with item: CollectionSectionItem)
}

public struct CollectionSectionItem {
  
  /// 更新SectionView的数据
  public var data: Any?
  
  /// 辅助用数据
  public var accessoryData: Any?
  /// SectionView代理
  public weak var delegate: AnyObject?
  
  /// 动态SectionView
  internal var reuseItem: ReuseItem
    
  /// Section视图的大小
  public var size: CGSize
  
  public init(_ reuseItem: ReuseItem = ReuseItem(UICollectionReusableView.self),
              data: Any? = nil,
              accessoryData: Any? = nil,
              delegate: AnyObject? = nil,
              size: CGSize = .zero) {
    
    self.reuseItem = reuseItem
    self.data = data
    self.accessoryData = accessoryData
    self.delegate = delegate
    self.size = size
  }
  
}
