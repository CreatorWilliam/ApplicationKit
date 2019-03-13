//
//  SegmentViewItem.swift
//  ComponentKit
//
//  Created by William Lee on 2018/7/3.
//  Copyright © 2018 William Lee. All rights reserved.
//

import UIKit

/// 段选数据，对文字，角标，图标进行封装
public struct SegmentViewItem: SegmentViewItemSourcable {
  
  public var badge: Int? = nil
  
  /// 未选中状态的图标
  public var normalImage: String? = nil
  /// 选中状态的图标
  public var selectedImage: String? = nil
  
  /// 未选中状态标题
  public var normalTitle: NSAttributedString
  /// 选中状态标题
  public var selectedTitle: NSAttributedString
  
  public init(title: String,
              normalColor: UIColor = UIColor.gray,
              selectedColor: UIColor = UIColor.black,
              normalFont: UIFont = UIFont.systemFont(ofSize: 14),
              selectedFont: UIFont = UIFont.systemFont(ofSize: 16),
              normalImage: String? = nil,
              selectedImage: String? = nil) {
    
    var normalAttributes: [NSAttributedString.Key: Any] = [:]
    normalAttributes[.foregroundColor] = normalColor
    normalAttributes[.font] = normalFont
    self.normalTitle = NSAttributedString(string: title, attributes: normalAttributes)
    
    var selectedAttributes: [NSAttributedString.Key: Any] = [:]
    selectedAttributes[.foregroundColor] = selectedColor
    selectedAttributes[.font] = selectedFont
    self.selectedTitle = NSAttributedString(string: title, attributes: selectedAttributes)
    
    self.normalImage = normalImage
    self.selectedImage = selectedImage
  }
  
  public init(_ normalAttributedText: NSAttributedString,
              _ selectedAttributedText: NSAttributedString) {
    
    self.normalTitle = normalAttributedText
    self.selectedTitle = selectedAttributedText
  }
  
}
