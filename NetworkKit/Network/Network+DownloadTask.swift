//
//  Network+DownloadTask.swift
//  NetworkKit
//
//  Created by William Lee on 2018/8/9.
//  Copyright © 2018 William Lee. All rights reserved.
//

import Foundation

public extension Network {
  
  typealias DownloadTaskCompleteAction = (_ tempLocation: URL?, _ status: NetworkStatus) -> Void
  
  /// 处理下载的数据
  ///
  /// - Parameters:
  ///   - resumeData: 包含继续下载所需信息，若不提供，则重新下载
  ///   - action: 下载完成或出现异常后进行回调，处理下载文件的临时地址及错误信息
  func download(with resumeData: Data? = nil, _ action: @escaping DownloadTaskCompleteAction) {
    
    //设置内部完成回调
    delegate.result.completeAction = { (delegate) in
      
      action(delegate.result.downloadedFile, delegate.result.status)
    }
    
    //设置代理类型
    delegate.taskType = .downloadTask
    
    //若有ResumeData，创建DownloadTask继续下载
    guard let resumeData = resumeData else {
      
      setupTask({ (session, urlRequest) -> URLSessionTask? in
        
        guard let urlRequest = urlRequest else { return nil }
        return session.downloadTask(with: urlRequest)
      })
      return
    }
    
    setupTask({ (session, urlRequest) -> URLSessionTask? in
      
      let task = session.downloadTask(withResumeData: resumeData)
      
      //使用ResumeData创建的下载任务，请求在currentRequest中，originalRequest为空
      //防止意外，若为空，则立刻取消此任务
      guard let urlRequest = self.delegate.task?.currentRequest else {
        
        self.delegate.task?.cancel()
        return nil
      }
      
      //保存请求
      self.delegate.request.urlRequest = urlRequest
      
      return task
    })
    
  }
  
  typealias DownloadTaskCancelHandle = (_ resumeData: Data?, _ status: NetworkStatus) -> Void
  
  /// 取消下载
  ///
  /// - Parameter action: 处理暂停下载的内容
  func cancelDownload(_ handle: @escaping DownloadTaskCancelHandle) {
    
    //取消下载任务，同时处理ResumeData
    (delegate.task as? URLSessionDownloadTask)?.cancel(byProducingResumeData: { (resumeData) in
      
      self.delegate.result.status =  .ok
      handle(resumeData, self.delegate.result.status)
    })
    
  }
  
}
