//
//  TextTool.swift
//  ComponentKit
//
//  Created by William Lee on 2018/6/4.
//  Copyright © 2018 William Lee. All rights reserved.
//

import UIKit

public struct TextTool {
  
}

public extension TextTool {
  
  /// 生成Html属性文字
  ///
  /// - Parameters:
  ///   - text: 标签文本
  ///   - font: 字体大小
  ///   - color: #FFFFFF格式的字符串
  /// - Returns: 属性文字
  static func htmlAttributed(_ text: String,
                             font: CGFloat? = nil,
                             color: String? = nil,
                             maxImageWidth: CGFloat = UIScreen.main.bounds.width) -> NSAttributedString? {
    
    var text = text
    let header = "<head>" + "<meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0, user-scalable=no\"> " + "<style>img{max-width: \(Int(maxImageWidth))px; height:auto;}</style>" + "</head>"
    if let color = color {

      text = "<font color='\(color)'>\(text)</div>"//默认字体颜色
    }
    if let font = font {

      text = "<font aize='\(font)px'>\(text)</div>"//默认字体大小
    }
    text = "<html>" + "\(header)" + "<body>" + "\(text)" + "</body></html>"
    
    guard let contentData = text.data(using: .unicode) else { return nil }
    guard let attributedText = try? NSAttributedString(data: contentData, options: [NSAttributedString.DocumentReadingOptionKey.documentType : NSAttributedString.DocumentType.html], documentAttributes: nil) else { return nil }
    
    return attributedText
  }

}
