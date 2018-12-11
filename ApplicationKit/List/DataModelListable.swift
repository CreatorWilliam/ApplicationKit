//
//  DataModelListable.swift
//  ComponentKit
//
//  Created by William Lee on 2018/8/20.
//  Copyright © 2018 William Lee. All rights reserved.
//

import Foundation

/// 列表数据模型协议
public protocol DataModelListable {
  
  /// 页码
  var pageNo: Int { set get }
  /// 是否有下一页
  var hasNextPage: Bool { set get }
  /// 分页请求参数
  func parameters(_ isNext: Bool) -> [String: Any]
}

// MARK: - DataModelListable默认实现
public extension DataModelListable {
  
  func parameters(_ isNext: Bool) -> [String: Any] {
    
    var parameters: [String: Any] = [:]
    if isNext == true {
      
      parameters["pageNo"] = self.pageNo + 1
      
    } else {
      
      parameters["pageNo"] = 1
    }
    parameters["pageSize"] = 10
    
    return parameters
  }
  
}
