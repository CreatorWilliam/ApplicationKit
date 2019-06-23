//
//  NetworkDelegate+URLSessionDataDelegate.swift
//  NetworkKit
//
//  Created by William Lee on 2018/8/9.
//  Copyright © 2018 William Lee. All rights reserved.
//

import Foundation

// MARK: - URLSessionDataDelegate
extension NetworkDelegate: URLSessionDataDelegate {
  
  /// Tells the delegate that the data task received the initial reply (headers) from the server.
  ///
  /// - parameter session:           The session containing the data task that received an initial reply.
  /// - parameter dataTask:          The data task that received an initial reply.
  /// - parameter response:          A URL response object populated with headers.
  /// - parameter completionHandler: A completion handler that your code calls to continue the transfer, passing a
  ///                                constant to indicate whether the transfer should continue as a data task or
  ///                                should become a download task.
  func urlSession(_ session: URLSession,
                  dataTask: URLSessionDataTask,
                  didReceive response: URLResponse,
                  completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
    
    delegateLog()
    //保存响应
    result.response = response as? HTTPURLResponse
    
    completionHandler(.allow)
  }
  
  /// Asks the delegate whether the data (or upload) task should store the response in the cache.
  ///
  /// - parameter session:           The session containing the data (or upload) task.
  /// - parameter dataTask:          The data (or upload) task.
  /// - parameter proposedResponse:  The default caching behavior. This behavior is determined based on the current
  ///                                caching policy and the values of certain received headers, such as the Pragma
  ///                                and Cache-Control headers.
  /// - parameter completionHandler: A block that your handler must call, providing either the original proposed
  ///                                response, a modified version of that response, or NULL to prevent caching the
  ///                                response. If your delegate implements this method, it must call this completion
  ///                                handler; otherwise, your app leaks memory.
  func urlSession(_ session: URLSession,
                  dataTask: URLSessionDataTask,
                  willCacheResponse proposedResponse: CachedURLResponse,
                  completionHandler: @escaping (CachedURLResponse?) -> Void) {
    
    delegateLog()
    completionHandler(proposedResponse)
  }
  
  /// Tells the delegate that the data task has received some of the expected data.
  ///
  /// - parameter session:  The session containing the data task that provided data.
  /// - parameter dataTask: The data task that provided data.
  /// - parameter data:     A data object containing the transferred data.
  func urlSession(_ session: URLSession,
                  dataTask: URLSessionDataTask,
                  didReceive data: Data) {
    
    delegateLog()
    
    //保存获取的数据
    result.data.append(data)
    
  }
  
  /// Tells the delegate that the data task was changed to a download task.
  ///
  /// - parameter session:      The session containing the task that was replaced by a download task.
  /// - parameter dataTask:     The data task that was replaced by a download task.
  /// - parameter downloadTask: The new download task that replaced the data task.
  func urlSession(_ session: URLSession,
                  dataTask: URLSessionDataTask,
                  didBecome downloadTask: URLSessionDownloadTask) {
    
    delegateLog()
  }
  
  /// Tells the delegate that the data task was changed to a streamtask.
  /// When the delegate’s URLSession:dataTask:didReceiveResponse:completionHandler: method decides to change the disposition from a data request to a stream, the session calls this delegate method to provide you with the new stream task. After this call, the session delegate receives no further delegate method calls related to the original data task.
  /// For requests that were pipelined, the stream task will only allow reading, and the object will immediately send the delegate message urlSession(_:writeClosedFor:). Pipelining can be disabled for all requests in a session by setting the httpShouldUsePipelining property on its URLSessionConfiguration object, or for individual requests by setting the httpShouldUsePipelining property on an NSURLRequest object.
  ///
  /// - Parameters:
  ///   - session: The session containing the task that was replaced by a stream task.
  ///   - dataTask: The data task that was replaced by a stream task.
  ///   - streamTask: The new stream task that replaced the data task.
  @available(iOS 9.0, macOS 10.11, tvOS 9.0, watchOS 2.0, *)
  func urlSession(_ session: URLSession,
                  dataTask: URLSessionDataTask,
                  didBecome streamTask: URLSessionStreamTask) {
    
    delegateLog()
  }
  
}
