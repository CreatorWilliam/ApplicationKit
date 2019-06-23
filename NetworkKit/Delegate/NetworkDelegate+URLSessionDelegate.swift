//
//  NetworkDelegate+URLSessionDelegate.swift
//  NetworkKit
//
//  Created by William Lee on 2018/8/9.
//  Copyright © 2018 William Lee. All rights reserved.
//

import Foundation

// MARK: - URLSessionDelegate
extension NetworkDelegate: URLSessionDelegate {
  
  /// Tells the delegate that the session has been invalidated.
  ///
  /// - parameter session: The session object that was invalidated.
  /// - parameter error:   The error that caused invalidation, or nil if the invalidation was explicit.
  func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
    
    delegateLog(message: error?.localizedDescription)
  }
  
  /// Requests credentials from the delegate in response to a session-level authentication request from the
  /// remote server.
  ///
  /// - parameter session:           The session containing the task that requested authentication.
  /// - parameter challenge:         An object that contains the request for authentication.
  /// - parameter completionHandler: A handler that your delegate method must call providing the disposition
  ///                                and credential.
  func urlSession(_ session: URLSession,
                  didReceive challenge: URLAuthenticationChallenge,
                  completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
    
    delegateLog()
    // TODO: 处理Session Level身份验证
    completionHandler(.performDefaultHandling, nil)
  }
  
  /// Tells the delegate that all messages enqueued for a session have been delivered.
  ///
  /// - parameter session: The session that no longer has any outstanding requests.
  func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
    
    delegateLog()
  }
  
}
