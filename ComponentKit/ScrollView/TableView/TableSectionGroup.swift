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
  public var header: TableSectionItem = TableSectionItem()
  
  // Footer
  public var footer: TableSectionItem = TableSectionItem()
  
  // Cells
  public var items: [TableCellItem] = []
  
  public init(header: TableSectionItem = TableSectionItem(),
              footer: TableSectionItem = TableSectionItem()) {
    
    self.header = header
    self.footer = footer
  }
  
}
