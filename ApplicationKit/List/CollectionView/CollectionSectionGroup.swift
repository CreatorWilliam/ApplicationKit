//
//  CollectionSectionGroup.swift
//  ComponentKit
//
//  Created by William Lee on 27/01/2018.
//  Copyright © 2018 William Lee. All rights reserved.
//

import UIKit

public struct CollectionSectionGroup {
  
  /// Header数据源
  public var header: CollectionSectionItem
  /// Footer数据源
  public var footer: CollectionSectionItem
  /// 元素行间距
  public var lineSpacing: CGFloat = 0
  /// 元素内间距
  public var interitemSpacing: CGFloat = 0
  /// 元素数据源
  public var items: [CollectionCellItem] = []
  /// Section内间距
  public var sectionInset: UIEdgeInsets = .zero
  
  /// 初始化一个Section样式及数据源
  ///
  /// - Parameters:
  ///   - sectionInset: Section内间距
  ///   - header: Header视图数据源
  ///   - footer: Footer视图数据源
  public init(sectionInset: UIEdgeInsets = .zero,
              header: CollectionSectionItem = CollectionSectionItem(),
              footer: CollectionSectionItem = CollectionSectionItem()) {
    
    self.sectionInset = sectionInset
    self.header = header
    self.footer = footer
  }
  
}
