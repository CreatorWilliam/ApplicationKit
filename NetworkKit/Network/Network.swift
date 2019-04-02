//
//  Network.swift
//  NetworkKit
//
//  Created by William Lee on 2018/8/9.
//  Copyright © 2018 William Lee. All rights reserved.
//

import Foundation

public class Network {
  
  /// 是否为Debug模式，1、开启后，将会打印WMReachability网络状态变更日志：2、与请求设置的Debug参数共同决定是否打印请求日志
  public static var isDebug: Bool = false
  
  // 配置默认的参数
  public static var defualtTimeout: TimeInterval = 20
  public static var defualtCachePolicy: NSURLRequest.CachePolicy = .reloadIgnoringLocalCacheData
  public static var configuration = URLSessionConfiguration.default
  
  
  internal let delegateQueue: OperationQueue = OperationQueue()
  internal let delegate: NetworkDelegate = NetworkDelegate()
  
  /// 保存请求中的代理，相应代理完成任务后，将会被移除
  internal static var delegatePool: [URLRequest: NetworkDelegate] = [:]
  
  /// 私有化
  private init() {}
  
}

// MARK: - HttpMethod
public extension Network {
  
  /// 请求方式
  ///
  /// - get: GET请求
  /// - post: POST请求
  /// - delete: DELETE请求
  enum HTTPMethod : String {
    
    case get     = "GET"
    case post    = "POST"
    case delete  = "DELETE"
    case put     = "PUT"
  }
  
}

// MARK: - Request
public extension Network {
  
  /// 进行请求
  ///
  /// - Parameters:
  ///   - httpMethod: 请求方式
  ///   - urlString: 请求地址
  ///   - isDebug: 是否为Debug模式, 默认开启，若Network为Debug模式，则打印输出
  /// - Returns: 用于链式调用，设置其他参数
  class func request(_ httpMethod: HTTPMethod,
                            _ urlString: String,
                            isDebug: Bool = true) -> Network {
    
    let network = Network()
    
    network.delegate.request.urlString = urlString
    network.delegate.request.httpMethod = httpMethod.rawValue
    network.delegate.isDebug = isDebug
    
    return network
  }
  
}

// MARK: - Setting
public extension Network {
  
  /// 设置查询语句
  ///
  /// - Parameter parameters: 查询参数
  /// - Returns: 用于链式调用，设置其他参数
  @discardableResult
  func query(_ parameters: Any) -> Network {
    
    self.delegate.request.queryParameters = parameters
    return self
  }
  
  /// 设置请求体
  ///
  /// - Parameter parameters: httpBody中的数据
  /// - Returns: 用于链式调用，设置其他参数
  @discardableResult
  func body(_ parameters: Any) -> Network {
    
    self.delegate.request.bodyParameters = parameters
    return self
  }
  
  /// 设置Form表单数据
  ///
  /// - Parameter data: Form表单数据
  /// - Returns: 用于链式调用，设置其他参数
  @discardableResult
  func form(_ data: Data) -> Network {
    
    self.delegate.request.formData = data
    return self
  }
  
  /// 设置请求内容类型
  ///
  /// - Parameter contentType: URLRequest中HTTPHeaderField的Content-Type
  /// - Returns: 用于链式调用，设置其他参数
  @discardableResult
  func httpHeaderField(_ parameters: [String: String]) -> Network {
    
    parameters.forEach({ self.delegate.request.httpHeaderFieldParameters[$0.key] = $0.value})
    return self
  }
  
  typealias ProgressAction = (_ totalCompletedBytes: Int64 ,_ totalExpectedBytes: Int64, _ partialData: Data?) -> Void
  
  /// 设置进度监听
  ///
  /// - Parameter action: 监听进度的行为,包含上传／下载进度
  /// - Returns: 用于链式调用，设置其他参数
  func progress(_ action: @escaping ProgressAction) -> Network {
    
    self.delegate.result.progressingAction = { (delegate) in
      
      guard let totalCompletedBytes = delegate.result.totalCompletedBytes,
            let totalExpectedBytes = delegate.result.totalExpectedBytes else { return }
      
      action(totalCompletedBytes, totalExpectedBytes, delegate.result.partialData)
    }
    
    return self
  }
  
}

// MARK: - Utility
internal extension Network {
  
  /// 将外部回调打包成内部回调
  ///
  /// - Parameter action: 任务完成后，执行的外部回调
  func setupResultComplete(_ action: @escaping NetworkResult.Action) {
    
    self.delegate.result.completeAction = { (delegate) in
      
      //执行外部回调
      action(delegate)
      
      //从代理池中移除
      guard let urlRequest = delegate.request.urlRequest else { return }
      Network.delegatePool.removeValue(forKey: urlRequest)
    }
  }
  
}
