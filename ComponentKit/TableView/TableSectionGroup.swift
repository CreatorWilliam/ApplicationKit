//
//  TableSectionGroup.swift
//  ComponentKit
//
//  Created by William Lee on 20/01/2018.
//  Copyright © 2018 William Lee. All rights reserved.
//

import UIKit

public struct TableSectionGroup {
  
  // Header
  public var header: TableSectionItem = TableSectionItem() {
    
    didSet {
      
      guard self.header.flexibleHeight == 0 else { return }
      self.isHeaderFlexible = true
      self.header.fixedHeight = UITableView.automaticDimension
    }
  }
  internal var isHeaderFlexible: Bool = false
  
  // Footer
  public var footer: TableSectionItem = TableSectionItem() {
    
    didSet {
      
      guard self.footer.flexibleHeight == 0 else  { return }
      self.isFooterFlexible = true
      self.footer.fixedHeight = UITableView.automaticDimension
    }
  }
  internal var isFooterFlexible: Bool = false
  
  // Cells
  public var items: [TableCellItem] = []
  internal var isCellFlexible: Bool = true
  
  public init(header: TableSectionItem = TableSectionItem(),
              footer: TableSectionItem = TableSectionItem()) {
    
    self.header = header
    self.footer = footer
  }
  
}
