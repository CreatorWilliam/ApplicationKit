//
//  API.swift
//  ApplicationKit
//
//  Created by William Lee on 2018/5/11.
//  Copyright © 2018 William Lee. All rights reserved.
//

import WMNetworkKit
import WMJSONKit

public class API {
  
  /// 是否为开发版
  public static var isDevelop: Bool = false
  /// 开发版本基地址
  public static var developBasePath: String = ""
  /// 生产版本基地址
  public static var productBasePath: String = ""
  
  /// 接口请求方式
  private var method: WMNetwork.HTTPMethod
  /// 接口路径
  private var path: String
  
  /// 查询参数
  private var queryParameters: Any?
  /// 请求体参数
  private var bodyParameters: Any?
  
  public init(method: WMNetwork.HTTPMethod, path: String? = nil, version: String? = nil, customPath: String? = nil) {
    
    let base = API.isDevelop ? API.developBasePath : API.productBasePath
    
    self.method = method
    if let customPath = customPath {
      
      self.path = customPath
      
    } else {
      
      self.path = base
    }
    
    if let version = version {
      
      self.path += "\(version)/"
    }
    
    if let subpath = path {
      
      self.path += subpath
    }
  }
  
}

public extension API {
  
  /// 设置查询参数
  func query(_ parameters: Any) -> Self {
    
    self.queryParameters = parameters
    return self
  }
  
  /// 设置请求题参数
  func body(_ parameters: Any) -> Self {
    
    self.bodyParameters = parameters
    return self
  }
 
  typealias ProgressHandle = (_ progress: Float) -> Void
  typealias CompleteHandle = (_ result: WMJSON) -> Void
  /// 进行请求
  func request(handle: @escaping CompleteHandle) {
    
    let api = self
    var network = WMNetwork.request(api.method, api.path, isDebug: true)
    if let query = api.queryParameters { network = network.query(query) }
    if let body = api.bodyParameters { network = network.body(body) }
    network.data({ (data, status) in
      
      guard let data = data else { return }
      var json = WMJSON()
      json.update(with: data)
      
      // 调试
      self.debugLog(json)
      DispatchQueue.main.async(execute: {
        
        handle(json)
      })
      
    })
    
  }
  
}

// MARK: - Utility
private extension API {
  
  func debugLog(_ json: WMJSON) {
    
    let api = self
    #if DEBUG
    DebugLog(api.path)
    if let query = api.queryParameters { DebugLog(query) }
    if let body = api.bodyParameters { DebugLog(body) }
    DebugLog(json)
    #endif
  }
  
}


















