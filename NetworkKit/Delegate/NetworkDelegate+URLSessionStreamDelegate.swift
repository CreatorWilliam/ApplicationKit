//
//  NetworkDelegate+URLSessionStreamDelegate.swift
//  NetworkKit
//
//  Created by William Lee on 2018/8/9.
//  Copyright © 2018 William Lee. All rights reserved.
//

import Foundation

// MARK: - URLSessionStreamDelegate
@available(iOS 9.0, macOS 10.11, tvOS 9.0, *)
extension NetworkDelegate: URLSessionStreamDelegate {
  
  /// Tells the delegate that the read side of the connection has been closed.
  ///
  /// - parameter session:    The session.
  /// - parameter streamTask: The stream task.
  func urlSession(_ session: URLSession,
                  readClosedFor streamTask: URLSessionStreamTask) {
    
    delegateLog()
  }
  
  /// Tells the delegate that the write side of the connection has been closed.
  ///
  /// - parameter session:    The session.
  /// - parameter streamTask: The stream task.
  func urlSession(_ session: URLSession,
                  writeClosedFor streamTask: URLSessionStreamTask) {
    
    delegateLog()
  }
  
  /// Tells the delegate that the system has determined that a better route to the host is available.
  ///
  /// - parameter session:    The session.
  /// - parameter streamTask: The stream task.
  func urlSession(_ session: URLSession,
                  betterRouteDiscoveredFor streamTask: URLSessionStreamTask) {
    
    delegateLog()
  }
  
  /// Tells the delegate that the stream task has been completed and provides the unopened stream objects.
  ///
  /// - parameter session:      The session.
  /// - parameter streamTask:   The stream task.
  /// - parameter inputStream:  The new input stream.
  /// - parameter outputStream: The new output stream.
  func urlSession(_ session: URLSession,
                  streamTask: URLSessionStreamTask,
                  didBecome inputStream: InputStream,
                  outputStream: OutputStream) {
    
    delegateLog()
  }
  
}
