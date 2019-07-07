//
//  MenuSelectionDataItem.swift
//  ApplicationKit
//
//  Created by William Lee on 2019/7/6.
//  Copyright © 2019 William Lee. All rights reserved.
//

import Foundation

public struct MenuSelectionDataItem {
  
  /// 选项标题
  public var title: String?
  /// 选项图标
  public var image: Any?
  /// 选项参数
  public var parameter: Any?
  /// 扩展数据
  public var accessoryData: Any?
  
  public init() {  }
  
}
