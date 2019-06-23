//
//  Network+Task.swift
//  NetworkKit
//
//  Created by William Lee on 2018/8/9.
//  Copyright © 2018 William Lee. All rights reserved.
//

import Foundation

// MARK: - Generalhandle
public extension Network {
  
  typealias StatusHandle = (_ status: NetworkStatus) -> Void
  
  /// 暂停任务
  func suspend(_ handle: StatusHandle) {
    
    delegate.task?.suspend()
    delegate.result.status = .ok
    handle(delegate.result.status)
  }
  
  func resume(_ handle: StatusHandle) {
    
    delegate.task?.resume()
    delegate.result.status = .ok
    handle(delegate.result.status)
  }
  
  /// 取消任务，任务将不可恢复，若想取消下载任务后，能继续下载，使用cancelDownload，获取resumeData，用于继续下载
  func cancel(_ handle: StatusHandle) {
    
    delegate.task?.cancel()
    delegate.result.status = .ok
    handle(delegate.result.status)
  }
  
}

// MARK: - Utility
internal extension Network {
  
  /// 创建并启动任务
  ///
  /// - Parameter action: 用于指明创建什么任务
  func setupTask(_ action: @escaping (_ session: URLSession, _ urlRequest: URLRequest?) -> URLSessionTask?) {
    
    //代理准备好请求
    guard delegate.prepareRequest() == true else { return }
    guard let urlRequest = delegate.request.urlRequest else { return }
    
    //创建回话
    let session = URLSession(configuration: Network.configuration,
                             delegate: delegate,
                             delegateQueue: Network.delegateQueue)
    
    //创建任务
    delegate.task = action(session, urlRequest)
    
    //启动任务
    delegate.task?.resume()
  }
  
}
