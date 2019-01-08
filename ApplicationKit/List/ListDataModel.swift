//
//  ListDataModel.swift
//  ComponentKit
//
//  Created by William Lee on 08/08/2018.
//  Copyright © 2018 William Lee. All rights reserved.
//

import JSONKit

public struct ListDataModel<Element: ItemListable>: DataModelListable {
  
  public var pageNo: Int = 1
  
  public var hasNextPage: Bool = false
  
  public var totalCount: Int = 0
  
  public var list: [Element] = []
  
  public init() { }
  
  public mutating func update(with page: JSON) {
    
    self.pageNo = page["pageNo"] ?? 1
    self.hasNextPage = page["isHasNext"] ?? false
    self.totalCount = page["totalCount"] ?? 0
    if self.pageNo == 1 { self.list.removeAll() }
    page["result"].forEach({ self.list.append(Element(list: $0.json)) })
  }
  
}
