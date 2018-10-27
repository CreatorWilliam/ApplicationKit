//
//  Pagable.swift
//  ComponentKit
//
//  Created by William Lee on 2018/7/13.
//  Copyright © 2018 William Lee. All rights reserved.
//

import Foundation

/// 遵循该协议，PageView翻页的时候，调用该方法，实现PageView与SegmentView同步
public protocol Pagable: class {
  
  /// 翻页
  ///
  /// - Parameters:
  ///   - index: 页码
  ///   - source: 发送翻页事件的源
  func page(to index: Int, withSource source: Pagable)
  
  /// 状态监听-开始翻页
  ///
  /// - Parameter index: 翻页开始时的索引
  ///   - source: 发送翻页事件的源
  func pageWillPage(at index: Int, withSource source: Pagable)
  
  /// 状态监听-结束翻页
  ///
  /// - Parameter index: 翻页结束时的索引
  ///   - source: 发送翻页事件的源
  func pageDidPage(to index: Int, withSource source: Pagable)
  
}

// MARK: - 默认实现
public extension Pagable {
  
  func pageWillPage(at index: Int, withSource source: Pagable) {
    
  }
  
  func pageDidPage(to index: Int, withSource source: Pagable) {
    
  }
  
}
