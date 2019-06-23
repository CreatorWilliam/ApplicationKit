//
//  NetworkResult.swift
//  NetworkKit
//
//  Created by William Lee on 2018/8/9.
//  Copyright © 2018 William Lee. All rights reserved.
//

import Foundation

struct NetworkResult {
  
  typealias Action = (_ delegate: NetworkDelegate) -> Void
  
  /// 进度回调
  var progressingAction: Action?
  /// 完成回调
  var completeAction: Action?
  
  /// 请求结果状态，会包含各种成功、异常信息
  var status: NetworkStatus = .prepareRequestFailure("未初始化")
  
  /// 请求的响应
  var response: HTTPURLResponse?
  
  /// 已上传／下载完成的字节数
  var totalCompletedBytes: Int64?
  /// 预计上传／下载的字节数
  var totalExpectedBytes: Int64?
  
  /// 已接收的数据
  var partialData: Data?
  
  /// 请求获取的数据
  var data: Data = Data()
  /// 下载完成后的文件路径
  var downloadedFile: URL?
  
}

extension NetworkResult {
  
  /// 将结果转化为Json字典
  var json: [String: Any]? {
    
    guard let temp = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) else { return nil }
    guard let json = temp as? [String: Any] else { return nil }
    
    return json
  }
  
}
