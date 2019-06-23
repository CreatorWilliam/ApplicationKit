//
//  Network+UploadTask.swift
//  NetworkKit
//
//  Created by William Lee on 2018/8/9.
//  Copyright © 2018 William Lee. All rights reserved.
//

import Foundation

public extension Network {
  
  typealias UploadTaskCompleteAction = (_ data: Data?, _ status: NetworkStatus) -> Void
  
  /// 上传文件内容
  ///
  /// - Parameters:
  ///   - file: 文件地址
  ///   - action: 上传完成或出现异常后进行回调，处理上传完成后服务器返回信息及错误信息
  func upload(with file: URL, _ action: @escaping UploadTaskCompleteAction) {
    
    //设置内部完成回调
    delegate.result.completeAction = { (delegate) in
  
      //执行外部设置的完成回调
      action(delegate.result.data, delegate.result.status)
    }
    
    //设置代理类型
    delegate.taskType = .uploadTask
    
    setupTask({ (session, request) -> URLSessionTask? in
      
      guard let request = request else { return nil }
      return session.uploadTask(with: request, fromFile: file)
    })
    
  }
  
  /// 上传数据
  ///
  /// - Parameters:
  ///   - data: 上传的数据，可以认为是httpBody
  ///   - action: 上传完成或出现异常后进行回调，处理上传完成后服务器返回信息及错误信息
  func upload(with data: Data, _ action: @escaping UploadTaskCompleteAction) {
    
    //设置内部完成回调
    delegate.result.completeAction = { (delegate) in
      
      action(delegate.result.data, delegate.result.status)
    }
    
    //设置代理类型
    delegate.taskType = .uploadTask
    
    setupTask({ (session, request) -> URLSessionTask? in
      
      guard let request = request else { return nil }
      return session.uploadTask(with: request, from: data)
    })

  }
  
}
