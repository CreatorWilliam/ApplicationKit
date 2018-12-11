//
//  ItemListable.swift
//  ComponentKit
//
//  Created by William Lee on 2018/8/20.
//  Copyright © 2018 William Lee. All rights reserved.
//

import JSONKit

/// 列表数据协议
public protocol ItemListable {
  
  init(list json: JSON)
  
}
