//
//  NetworkDelegate+URLSessionDownloadDelegate.swift
//  NetworkKit
//
//  Created by William Lee on 2018/8/9.
//  Copyright © 2018 William Lee. All rights reserved.
//

import Foundation

// MARK: - URLSessionDownloadDelegate
extension NetworkDelegate: URLSessionDownloadDelegate {
  
  /// Tells the delegate that the download task has resumed downloading.
  ///
  /// - parameter session:            The session containing the download task that finished.
  /// - parameter downloadTask:       The download task that resumed. See explanation in the discussion.
  /// - parameter fileOffset:         If the file's cache policy or last modified date prevents reuse of the
  ///                                 existing content, then this value is zero. Otherwise, this value is an
  ///                                 integer representing the number of bytes on disk that do not need to be
  ///                                 retrieved again.
  /// - parameter expectedTotalBytes: The expected length of the file, as provided by the Content-Length header.
  ///                                 If this header was not provided, the value is NSURLSessionTransferSizeUnknown.
  func urlSession(_ session: URLSession,
                  downloadTask: URLSessionDownloadTask,
                  didResumeAtOffset fileOffset: Int64,
                  expectedTotalBytes: Int64) {
    
    delegateLog()
    
  }
  
  /// Periodically informs the delegate about the download’s progress.
  ///
  /// - parameter session:                   The session containing the download task.
  /// - parameter downloadTask:              The download task.
  /// - parameter bytesWritten:              The number of bytes transferred since the last time this delegate
  ///                                        method was called.
  /// - parameter totalBytesWritten:         The total number of bytes transferred so far.
  /// - parameter totalBytesExpectedToWrite: The expected length of the file, as provided by the Content-Length
  ///                                        header. If this header was not provided, the value is
  ///                                        `NSURLSessionTransferSizeUnknown`.
  func urlSession(_ session: URLSession,
                  downloadTask: URLSessionDownloadTask,
                  didWriteData bytesWritten: Int64,
                  totalBytesWritten: Int64,
                  totalBytesExpectedToWrite: Int64) {
    
    delegateLog()
    
    result.totalCompletedBytes = totalBytesWritten
    result.totalExpectedBytes = totalBytesExpectedToWrite
    
    //执行进度回调
    result.status = .progress
    result.progressingAction?(self)
  }
  
  /// Tells the delegate that a download task has finished downloading.
  ///
  /// - parameter session:      The session containing the download task that finished.
  /// - parameter downloadTask: The download task that finished.
  /// - parameter location:     A file URL for the temporary file. Because the file is temporary, you must either
  ///                           the file for reading or move it to a permanent location in your app’s sandbox
  ///                           container directory before returning from this delegate method.
  func urlSession(_ session: URLSession,
                  downloadTask: URLSessionDownloadTask,
                  didFinishDownloadingTo location: URL) {
    
    delegateLog()
    
    //保存下载完成后，临时文件的地址
    result.downloadedFile = location
    
    //执行完成回调
    result.status = .complete
    result.completeAction?(self)
  }
  
}
