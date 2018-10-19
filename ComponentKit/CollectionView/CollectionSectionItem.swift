//
//  CollectionSectionItem.swift
//  ComponentKit
//
//  Created by William Lee on 2018/10/17.
//  Copyright © 2018 William Lee. All rights reserved.
//

import Foundation

public struct CollectionSectionItem {
  
  /// 更新SectionView的数据
  public var data: Any?
  
  /// 不重用的View
  internal var view: UIView?
  
  /// SectionView代理
  public weak var delegate: AnyObject?
  
  /// SectionView重用符号
  internal var reuseItem: ReuseItem?
  
  /// Section视图的大小
  public var size: CGSize
  
  public init(size: CGSize = .zero) {
    
    self.size = size
  }
}
