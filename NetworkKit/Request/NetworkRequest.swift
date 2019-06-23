//
//  NetworkRequest.swift
//  NetworkKit
//
//  Created by William Lee on 2018/8/9.
//  Copyright © 2018 William Lee. All rights reserved.
//

import Foundation

struct NetworkRequest {
  
  /// 请求地址
  var urlString: String?
  
  /// 查询参数
  var queryParameters: Any?
  
  /// 请求体参数
  var bodyParameters: Any?
  
  /// Form表单数据
  var formData: Data?
  
  /// 请求方式
  var httpMethod: String = "GET"
  
  /// 内容类型
  var httpHeaderFieldParameters: [String: String] = ["content-type": "application/json; charset=utf-8"]
  
  /// 保存请求
  var urlRequest: URLRequest?
}

extension NetworkRequest {
  
  /// 准备请求
  ///
  /// - Returns: 生成的请求
  /// - Throws: NetworkStatus.requestFailureReason，包含生成请求失败的原因
  mutating func prepare() -> NetworkStatus {
    
    // 1、获取请求地址
    guard let urlString = urlString else {
      
      return NetworkStatus.prepareRequestFailure("Reason：请求地址为空")
    }
    
    // 2、请求地址
    var urlStringWithQuery = urlString
    
    // 3、生成Query，并附加到请求地址后
    if let query = queryParameters as? [String: Any], query.count > 0 {
      
      urlStringWithQuery.append("?")
      urlStringWithQuery.append(query.map { "\($0)=\($1)" }.joined(separator: "&"))
      
    }
    
    // 4、对请求地址进行编码
    guard let urlStringWithQueryAndEncod = urlStringWithQuery.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
      
      return NetworkStatus.prepareRequestFailure("Reason：对请求地址及请求头编码失败：\nURLString:\(urlStringWithQuery)")
    }
    
    // 5、根据编码后的请求地址生成URL
    guard let url = URL(string: urlStringWithQueryAndEncod) else {
      
      return NetworkStatus.prepareRequestFailure("Reason：无法生成URL:\(urlStringWithQueryAndEncod)")
    }
    
    // 6、生成URLRequest
    var request = URLRequest(url: url)
    
    // 7、配置请求方式
    request.httpMethod = httpMethod
    
    // 8、配置请求域
    httpHeaderFieldParameters.forEach({ (key, value) in
      
      request.setValue(value, forHTTPHeaderField: key)
    })
    
    // 9、配置请求体
    if httpMethod != "GET" {
      
      if let formData = formData {
        
        request.httpBody = formData
        
      } else if let body = bodyParameters {
        
        guard let temp = try? JSONSerialization.data(withJSONObject: body, options: JSONSerialization.WritingOptions.prettyPrinted) else {
          
          return NetworkStatus.prepareRequestFailure("Reason：请求体参数转化成Json Data失败：\nBody:\(body)")
        }
        request.httpBody = temp
        
      } else {
        
        // Nothing
      }
      
    }
    
    urlRequest = request
    
    return .ok
  }
  
}
