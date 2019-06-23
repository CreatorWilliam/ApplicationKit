//
//  Network+DataTask.swift
//  NetworkKit
//
//  Created by William Lee on 2018/8/9.
//  Copyright © 2018 William Lee. All rights reserved.
//

import Foundation

public extension Network {
  
  typealias DataTaskCompleteAction = (_ data: Data?, _ status: NetworkStatus) -> Void
  
  /// 处理Data数据
  ///
  /// - Parameter action: 获取Data数据或出现异常后进行回调，处理Data数据集错误信息
  func data(_ action: @escaping DataTaskCompleteAction) {
    
    //外部完成回调打包成内部完成回调
    delegate.result.completeAction = { (delegate) in
      
      action(delegate.result.data, delegate.result.status)
    }
    
    //设置代理类型
    delegate.taskType = .dataTask
    
    //启动任务
    setupTask({ (session, request) -> URLSessionTask? in
      
      guard let urlRequest = request else { return nil }
      return session.dataTask(with: urlRequest)
    })
    
  }
  
}
