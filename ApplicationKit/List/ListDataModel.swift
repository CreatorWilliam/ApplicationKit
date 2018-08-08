//
//  ListDataModel.swift
//  ApplicationKit
//
//  Created by William Lee on 08/08/2018.
//  Copyright © 2018 William Lee. All rights reserved.
//

import WMJSONKit

public struct ListDataModel<Element: ItemListable>: DataModelListable {
  
  public var pageNo: Int = 1
  
  public var hasNextPage: Bool = false
  
  public var list: [Element] = []
  
  public init() { }
  
  public mutating func update(with page: WMJSON) {
    
    self.pageNo = page["pageNo"] ?? 1
    self.hasNextPage = page["isHasNext"] ?? false
    if self.pageNo == 1 { self.list.removeAll() }
    page["result"].forEach({ self.list.append(Element($0)) })
  }
  
}
