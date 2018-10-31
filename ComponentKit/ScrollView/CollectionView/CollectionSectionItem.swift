//
//  CollectionSectionItem.swift
//  ComponentKit
//
//  Created by William Lee on 2018/10/17.
//  Copyright © 2018 William Lee. All rights reserved.
//

import Foundation

// 遵循该协议后的SectionView，Server才可以更新SectionView
public protocol CollectionSectionItemUpdatable {
  
  func update(with item: CollectionSectionItem)
}

public struct CollectionSectionItem {
  
  /// 更新SectionView的数据
  public var data: Any?
  
  /// 不重用的View
  internal var view: UIView?
  
  /// SectionView代理
  public weak var delegate: AnyObject?
  
  /// SectionView重用符号
  internal var reuseItem: ReuseItem
  
  /// Section视图的大小
  public var size: CGSize
  
  public init(_ reuseItem: ReuseItem = ReuseItem(UICollectionReusableView.self),
              data: Any? = nil,
              delegate: AnyObject? = nil,
              size: CGSize = .zero) {
    
    self.reuseItem = reuseItem
    self.data = data
    self.delegate = delegate
    self.size = size
  }
  
}
