//
//  NetworkDelegate+URLSessionTaskDelegate.swift
//  NetworkKit
//
//  Created by William Lee on 2018/8/9.
//  Copyright © 2018 William Lee. All rights reserved.
//

import Foundation

// MARK: - URLSessionTaskDelegate
extension NetworkDelegate: URLSessionTaskDelegate {
  
  /// Tells the delegate that the remote server requested an HTTP redirect.
  ///
  /// - parameter session:           The session containing the task whose request resulted in a redirect.
  /// - parameter task:              The task whose request resulted in a redirect.
  /// - parameter response:          An object containing the server’s response to the original request.
  /// - parameter request:           A URL request object filled out with the new location.
  /// - parameter completionHandler: A closure that your handler should call with either the value of the request
  ///                                parameter, a modified URL request object, or NULL to refuse the redirect and
  ///                                return the body of the redirect response.
  func urlSession(_ session: URLSession,
                  task: URLSessionTask,
                  willPerformHTTPRedirection response: HTTPURLResponse,
                  newRequest request: URLRequest,
                  completionHandler: @escaping (URLRequest?) -> Void) {
    
    delegateLog()
    
    // TODO: 处理重定向响应及请求
    completionHandler(request)
  }
  
  /// Requests credentials from the delegate in response to an authentication request from the remote server.
  ///
  /// - parameter session:           The session containing the task whose request requires authentication.
  /// - parameter task:              The task whose request requires authentication.
  /// - parameter challenge:         An object that contains the request for authentication.
  /// - parameter completionHandler: A handler that your delegate method must call providing the disposition
  ///                                and credential.
  func urlSession(_ session: URLSession,
                  task: URLSessionTask,
                  didReceive challenge: URLAuthenticationChallenge,
                  completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
    
    delegateLog()
    
    // TODO: 处理Task Level身份验证
    completionHandler(URLSession.AuthChallengeDisposition.performDefaultHandling, nil)
  }
  
  /// Tells the delegate when a task requires a new request body stream to send to the remote server.
  ///
  /// - parameter session:           The session containing the task that needs a new body stream.
  /// - parameter task:              The task that needs a new body stream.
  /// - parameter completionHandler: A completion handler that your delegate method should call with the new body stream.
  func urlSession(_ session: URLSession,
                  task: URLSessionTask,
                  needNewBodyStream completionHandler: @escaping (InputStream?) -> Void) {
    
    delegateLog()
  }
  
  /// Periodically informs the delegate of the progress of sending body content to the server.
  ///
  /// - parameter session:                  The session containing the data task.
  /// - parameter task:                     The data task.
  /// - parameter bytesSent:                The number of bytes sent since the last time this delegate method was called.
  /// - parameter totalBytesSent:           The total number of bytes sent so far.
  /// - parameter totalBytesExpectedToSend: The expected length of the body data.
  func urlSession(_ session: URLSession,
                  task: URLSessionTask,
                  didSendBodyData bytesSent: Int64,
                  totalBytesSent: Int64,
                  totalBytesExpectedToSend: Int64) {
    
    delegateLog()
    
    result.totalCompletedBytes = totalBytesSent
    result.totalExpectedBytes = totalBytesExpectedToSend
    
    //执行进度回调
    result.status = .progress
    result.progressingAction?(self)
    
  }
  
  /// Tells the delegate that the task finished transferring data. Server errors are not reported through the error parameter. The only errors your delegate receives through the error parameter are client-side errors, such as being unable to resolve the hostname or connect to the host.
  ///
  /// - parameter session: The session containing the task whose request finished transferring data.
  /// - parameter task:    The task whose request finished transferring data.
  /// - parameter error:   If an error occurred, an error object indicating how the transfer failed, otherwise nil.
  func urlSession(_ session: URLSession,
                  task: URLSessionTask,
                  didCompleteWithError error: Error?) {
    
    delegateLog(message: error?.localizedDescription)
    
    //执行完成回调
    result.status = .complete
    result.completeAction?(self)
    //任务完成后，关闭Session，释放Delegate
    session.finishTasksAndInvalidate()
  }
  
  /// Tells the delegate that the session finished collecting metrics for the task.
  ///
  /// - parameter session: The session collecting the metrics.
  /// - parameter task:    The task whose metrics have been collected.
  /// - parameter metrics: The collected metrics.
  //  @available(iOS 10.0, macOS 10.12, tvOS 10.0, *)
  @available(iOS 10.0, *)
  func urlSession(_ session: URLSession,
                  task: URLSessionTask,
                  didFinishCollecting metrics: URLSessionTaskMetrics) {
    
    delegateLog()
  }
  
}
