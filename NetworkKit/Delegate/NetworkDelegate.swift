//
//  NetworkDelegate.swift
//  NetworkKit
//
//  Created by William Lee on 2018/8/9.
//  Copyright © 2018 William Lee. All rights reserved.
//

import Foundation

internal class NetworkDelegate : NSObject {
  
  /// 是否为Debug模式，然后和请求的Debug参数共同决定是否打印相关日志
  internal var isDebug: Bool = false
  /// 任务类型
  internal var taskType: NetworkDelegate.TaskType = .dataTask
  /// 任务
  internal weak var task: URLSessionTask?
  /// 对网络请求的封装
  internal var request: NetworkRequest = NetworkRequest()
  /// 对网络响应结果的封装
  internal var result: NetworkResult = NetworkResult()
  
  /// 准备好请求，会剔除重复的请求
  internal func prepareRequest() -> Bool {
    
    result.status = request.prepare()
    
    /// 判断是否为重复的请求
    switch result.status {
    case .ok: return true
    default: return false
    }
  }
  
  deinit {
    
    delegateLog("Delegate is Dead")
  }
  
}

// MARK: - TaskType
internal extension NetworkDelegate {
  
  enum TaskType {
    
    case dataTask
    case downloadTask
    case uploadTask
  }
}

// MARK: - Utility
internal extension NetworkDelegate {
  
  /// 打印
  ///
  /// - Parameters:
  ///   - message: 消息
  ///   - file: 调用时，所在文件路径
  ///   - line: 调用时，所在行
  ///   - functionName: 调用时，所在函数
  func delegateLog(message: String? = nil, _ file: String = #file, _ line: Int = #line, _ functionName: String = #function) {
    
    guard Network.isDebug && isDebug else { return }
    let fileName = file.components(separatedBy: "/").last ?? ""
    print("File:\(fileName)  Line:\(line)  Function:\(functionName)")
    guard let message = message else { return }
    print("Message:\(message)")
  }
  
}
