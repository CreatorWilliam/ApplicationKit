//
//  MenuDataItem.swift
//  ApplicationKit
//
//  Created by William Lee on 2019/7/6.
//  Copyright © 2019 William Lee. All rights reserved.
//

import Foundation

public struct MenuDataItem {
  
  /// 选项标题
  public var title: String?
  /// 选项图标
  public var imageName: String?
  /// 选项图标
  public var imageURL: URL?
  /// 选项参数
  public var parameter: AnyHashable?
  /// 扩展数据
  public var accessoryData: Any?
  
  public init(title: String? = nil) {
    
    self.title = title
  }
  
  public init(imageName name: String?, title: String?) {
    
    self.title = title
    self.imageName = name
  }
  
  public init(imageURL string: String?, title: String?) {
    
    self.title = title
    guard let url = string else { return }
    if url.isEmpty == true { return }
    self.imageURL = URL(string: url)
  }
  
  public init(imageURL url: URL?, title: String?) {
    
    self.title = title
    self.imageURL = url
  }
  
}
