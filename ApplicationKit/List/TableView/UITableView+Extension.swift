//
//  UITableView+Extension.swift
//  ComponentKit
//
//  Created by William Lee on 27/12/17.
//  Copyright © 2018 William Lee. All rights reserved.
//

import UIKit

public struct ReuseItem {
  
  public var `class`: AnyClass?
  public var id: String
  
  public init(_ cellClass: AnyClass, _ id: String? = nil) {
    
    self.class = cellClass
    self.id = id ?? NSStringFromClass(cellClass)
  }
  
}

extension ReuseItem: Hashable {
  
  public var hashValue: Int {
    
    return (self.id.hashValue + (self.class?.hash() ?? 0)).hashValue
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






