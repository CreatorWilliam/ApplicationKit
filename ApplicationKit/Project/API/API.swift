//
//  API.swift
//  ApplicationKit
//
//  Created by William Lee on 2018/5/11.
//  Copyright © 2018 William Lee. All rights reserved.
//

import Foundation
import NetworkKit
import JSONKit

open class API {
  
  /// 接口主机地址
  public static var host: String = ""
  
  /// 接口请求方式
  private var method: Network.HTTPMethod
  /// 接口路径
  private var path: String
  /// 请求头参数
  private var headerFieldParameters: [String: String]?
  /// 查询参数
  private var queryParameters: Any?
  /// 请求体参数
  private var bodyParameters: Any?
  /// 表单提交用的请求体
  private var formParameters: Data?
  
  // MARK: - Init
  
  /// 创建API对象，提供请求路径，API.host会参与路径的拼接
  ///
  /// - Parameters:
  ///   - method: 请求方式
  ///   - path: 请求的子路径
  public init(method: Network.HTTPMethod, path: String) {
    
    self.method = method
    self.path = API.host + path
  }
  
  /// 创建API对象, 需提供完整的请求路径，API.host不会参与路径的拼接
  ///
  /// - Parameters:
  ///   - method: 请求方式
  ///   - customPath: 自定义的全路径
  public init(method: Network.HTTPMethod, customPath: String) {
    
    self.method = method
    self.path = customPath
  }
  
  // MARK: - Request
  
  public typealias ProgressHandle = (_ progress: Float) -> Void
  public typealias CompleteHandle = (_ result: JSON) -> Void
  
  /// 发起请求
  open func request(handle: @escaping CompleteHandle) {
    
    let api = self
    
    let network = Network.request(api.method, api.path, isDebug: true)
    
    if let query = api.queryParameters { network.query(query) }
    if let body = api.bodyParameters { network.body(body) }
    if let headerField = api.headerFieldParameters { network.httpHeaderField(headerField) }
    if let data = api.formParameters { network.form(data) }
    
    network.data({ (data, status) in
      
      guard let data = data else { return }
      var json = JSON()
      json.update(from: data)
      
      // 调试
      self.debugLog(json)
      DispatchQueue.main.async(execute: {
        
        handle(json)
      })
      
    })
    
  }
  
  /// 进行请求
  open func request(progressHandle: @escaping ProgressHandle, completionHandle: @escaping CompleteHandle) {
    
    let api = self
    
    let network = Network.request(api.method, api.path, isDebug: true)
    
    if let query = api.queryParameters { network.query(query) }
    if let body = api.bodyParameters { network.body(body) }
    if let headerField = api.headerFieldParameters { network.httpHeaderField(headerField) }
    if let data = api.formParameters { network.form(data) }
    
    network.progress({ (totalCompletedBytes, totalExpectedBytes, partialData) in
      
      DispatchQueue.main.async {
        
        progressHandle(Float(totalCompletedBytes) / Float(totalExpectedBytes))
      }
      
    }).data({ (data, status) in
      
      guard let data = data else { return }
      var json = JSON()
      json.update(from: data)
      
      // 调试
      self.debugLog(json)
      DispatchQueue.main.async(execute: {
        
        completionHandle(json)
      })
      
    })
    
  }
  
}

// MARK: - Parameters
public extension API {
  
  func headerField(_ parameters: [String: String]) -> Self {
    
    self.headerFieldParameters = parameters
    return self
  }
  
  /// 设置查询参数
  func query(_ parameters: Any?) -> Self {
    
    self.queryParameters = parameters
    return self
  }
  
  /// 设置请求题参数
  func body(_ parameters: Any?) -> Self {
    
    self.bodyParameters = parameters
    return self
  }
  
  /// 设置表单
  ///
  /// - Parameter data: 表单数据
  func form(_ data: Data) -> Self {
    
    self.formParameters = data
    return self
  }
  
}

// MARK: - Utility
private extension API {
  
  func debugLog(_ json: JSON) {
    
    #if DEBUG
    let api = self
    DebugLog(api.path)
    if let header = api.headerFieldParameters { DebugLog(JSON(header))}
    if let query = api.queryParameters { DebugLog(JSON(query)) }
    if let body = api.bodyParameters { DebugLog(JSON(body)) }
    DebugLog(json)
    #endif
  }
  
}
