//
//  CollectionSectionGroup.swift
//  ComponentKit
//
//  Created by William Lee on 27/01/2018.
//  Copyright © 2018 William Lee. All rights reserved.
//

import Foundation

public struct CollectionSectionGroup {
  
  public var header: CollectionSectionItem
  
  public var footer: CollectionSectionItem
  
  public var lineSpacing: CGFloat = 0
  public var interitemSpacing: CGFloat = 0
  
  public var items: [CollectionCellItem] = []
  
  public init(header: CollectionSectionItem = CollectionSectionItem(),
              footer: CollectionSectionItem = CollectionSectionItem()) {
    
    self.header = header
    self.footer = footer
  }
  
}
