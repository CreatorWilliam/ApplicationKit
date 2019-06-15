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
    
    defer { handle(delegate.result.status) }
    
    guard let task = handleTask() else { return }
    
    task.suspend()
    delegate.result.status = .ok
  }
  
  func resume(_ handle: StatusHandle) {
    
    defer { handle(delegate.result.status) }
    
    guard let task = handleTask() else { return }
    
    task.resume()
    delegate.result.status = .ok
    
  }
  
  /// 取消任务，任务将不可恢复，若想取消下载任务后，能继续下载，使用cancelDownload，获取resumeData，用于继续下载
  func cancel(_ handle: StatusHandle) {
    
    defer { handle(delegate.result.status) }
    
    guard let task = handleTask() else { return }
    
    task.cancel()
    
    //保证从代理池中移除
    guard let urlRequest = delegate.request.urlRequest else {
      
      delegate.result.status = .requestFailure("Reason：无法获取任务对应的URLRequest")
      return
    }
    Network.delegatePool.removeValue(forKey: urlRequest)
    delegate.result.status = .ok
  }
  
}

// MARK: - Utility
internal extension Network {
  
  /// 创建并启动任务
  ///
  /// - Parameter action: 用于指明创建什么任务
  func setupTask(_ action: (_ session: URLSession, _ urlRequest: URLRequest?) -> URLSessionTask?) {
    
    //无需在失败的时候设置错误状态，已经在上一步的prepare()进行了处理
    guard let urlRequest = self.delegate.request.urlRequest else { return }
    
    if Network.delegatePool.contains(where: { urlRequest == $0.key }) { return }
    
    //创建回话
    let session = URLSession(configuration: Network.configuration,
                             delegate: self.delegate,
                             delegateQueue: self.delegateQueue)
    
    //获取请求
    self.delegate.result.status = delegate.request.prepare()
    
    //创建任务
    guard let task = action(session, urlRequest) else {
      
      self.delegate.result.status = .requestFailure("Reason:创建URLSessionTask失败")
      return
    }
    
    //保存任务
    self.delegate.task = task
    
    //将代理加入代理池，后续会对任务的精细化操作
    Network.delegatePool[urlRequest] = self.delegate
    //启动任务
    self.delegate.task?.resume()
  }
  
  /// 依赖内容相同URLRequest，获取代理池中的代理，进行操作
  ///
  /// - Parameter action: 指明如何操作任务
  func handleTask() -> URLSessionTask? {
    
    var task: URLSessionTask?
    
    //获取请求
    self.delegate.result.status = delegate.request.prepare()
    
    //无需在失败的时候设置错误状态，已经在上一步的prepare()进行了处理
    guard let urlRequest = delegate.request.urlRequest else { return task }
    
    //根据URLRequest获取一个存在的Delegate，继而获取对应任务
    guard let delegate = findDelegate(urlRequest) else {
      
      self.delegate.result.status = NetworkStatus.requestFailure("Reason:内部未通过\(urlRequest)找到Delegate")
      return task
    }
    
    //判断delegate的task是否存在，不存在则保存异常状态
    if let temp = delegate.task {
      
      task = temp
      
    } else {
      
      self.delegate.result.status = NetworkStatus.requestFailure("Reason:内部未找到Task")
      
    }
    
    return task
  }
  
  /// 根据给的URLRequest在DelegatePool中查找Delegate.
  /// 不知为何，相同内容的URLRequest，比较却不相同，无法取出值，此处使用hashValue
  ///
  /// - Parameter urlRequest: 查找条件
  /// - Returns: 结果
  func findDelegate(_ urlRequest: URLRequest) -> NetworkDelegate? {
    
    for (temp, delegate) in Network.delegatePool {
      
      guard temp.hashValue == urlRequest.hashValue else { continue }
      
      return delegate
      
    }
    
    return nil
  }
  
}
