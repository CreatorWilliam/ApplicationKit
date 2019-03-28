//
//  UITableView+Extension.swift
//  ComponentKit
//
//  Created by William Lee on 27/12/17.
//  Copyright © 2018 William Lee. All rights reserved.
//

import UIKit

public struct ReuseItem {
  
  public let `class`: AnyClass
  public let id: String
  
  public init(_ cellClass: AnyClass, _ id: String? = nil) {
    
    self.class = cellClass
    self.id = id ?? NSStringFromClass(cellClass)
  }
  
}

extension ReuseItem: Hashable {
  
  public func hash(into hasher: inout Hasher) {
    
    hasher.combine(self.class.hash())
    hasher.combine(self.id)
  }
  
  public static func ==(lhs: ReuseItem, rhs: ReuseItem) -> Bool {
    
    return lhs.class == rhs.class && lhs.id == rhs.id
  }
  
  
}

public extension UITableView {
  
  func register(cells: [ReuseItem]) {
    
    cells.forEach { self.register($0.class, forCellReuseIdentifier: $0.id) }
  }
  
  func register(sectionViews: [ReuseItem]) {
    
    sectionViews.forEach { self.register($0.class, forHeaderFooterViewReuseIdentifier: $0.id) }
  }
  
}
