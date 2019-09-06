//
//  TextModel.swift
//  ComponentKit
//
//  Created by William Lee on 13/05/2018.
//  Copyright © 2018 William Lee. All rights reserved.
//

import UIKit
import CoreText

public struct TextModel {
  
  /// 文本颜色
  public var textColor: UIColor = UIColor.black
  /// 文本字体
  public var font: UIFont = UIFont.systemFont(ofSize: 15)
  /// 字间距
  public var fontSpace: CGFloat = 0
  
  public var faceOffset: CGFloat = 2
  /// 标签图片尺寸
  public var tagImgSize: CGSize = CGSize(width: 14, height: 14)
  
  /// 行间距
  public var lineSpace: CGFloat = 4
  
  /// 默认为-1 （<0 为不限制行数）
  public var numberOfLines: Int = -1
  
  /// 高亮圆角
  public var highlightBackgroundRadius: CGFloat = 2
  /// 高亮背景色
  public var highlightBackgroundColor: UIColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1)
  /// 高亮背景偏移
  public var highlightBackgroundOffset: CGFloat = 0
  /// 高亮背景高度
  public var highlightBackgroundAdjustHeight: CGFloat = 0
  
  /// 链接的颜色
  public var urlColor: UIColor = UIColor.blue
  /// 号码的颜色
  public var numberColor: UIColor = UIColor.blue
  /// @字符串的颜色
  public var atSomeOneColor: UIColor = UIColor.blue
  
  /// url是否需要下划线
  public var urlUnderLine = true
  /// 是否替换url为文本
  public var hasURLPlaceholder: Bool = true
  /// urlShouldInstead 为true时 此值才有用 替换连接的文本
  public var urlPlaceholder = "网页连接"
  
  public var text: String = "" {
    
    didSet { self.update() }
  }
  public var attributedText = NSMutableAttributedString()
  
  public init() {
    
  }
  
}

public extension TextModel {
  
  /// 根据文本得到行高
  ///
  /// - Parameters:
  ///   - text: 文本
  ///   - rectSize: CGSize
  ///   - styleModel: 样式
  /// - Returns: 高度
  func height(rectSize: CGSize) -> CGFloat {
    
    let viewRect = CGRect(x: 0, y: 0, width: rectSize.width, height: rectSize.height)
    
    // 创建一个用来描画文字的路径，其区域为当前视图的bounds CGPath
    let pathRef = CGMutablePath()
    pathRef.addRect(viewRect)
    
    let framesetterRef = CTFramesetterCreateWithAttributedString(attributedText as CFAttributedString)
    
    // 创建由framesetter管理的frame 是描画文字的一个视图范围 CTFrame
    let framesetter = CTFramesetterCreateFrame(framesetterRef, CFRangeMake(0, 0), pathRef, nil)
    
    let lines = CTFrameGetLines(framesetter)
    let lineCount = CFArrayGetCount(lines)
    
    var frameHeight: CGFloat = 0
    if self.numberOfLines < 0 {
      
      frameHeight = CGFloat(lineCount) * (self.font.lineHeight + self.lineSpace) + self.lineSpace
      
    } else {
      
      frameHeight = CGFloat(self.numberOfLines) * (self.font.lineHeight + self.lineSpace) + self.lineSpace
    }
    
    // 四舍五入函数，否则可能会出现一条黑线
    return CGFloat(roundf(Float(frameHeight)))
  }
  
}

public extension TextModel {
  
  // url
  func runsURL(){
    
    let muStr = self.attributedText.mutableString
    let regular = String(format: "<a href='(((http[s]{1}|ftp)://[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%@^&*+?:_/=<>]*)?)|(www.[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%@^&*+?:_/=<>]*)?))'>((?!<\\/a>).)*<\\/a>|(((http[s]{0,1}|ftp)://[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%@^&*+?:_/=<>]*)?)|(www.[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%@^&*+?:_/=<>]*)?))", "%","%","%","%")
    
    guard let regex = try? NSRegularExpression(pattern: regular, options: .caseInsensitive ) else { return }
    let matches = regex.matches(in: muStr as String, options: .reportProgress , range: NSMakeRange(0,muStr.length))
    
    var forIndex = 0
    var startIndex = -1
    for match in matches {
      
      let matchRange = match.range
      if startIndex == -1 {
        
        startIndex = matchRange.location
        
      } else {
        
        startIndex = matchRange.location - forIndex
        
      }
      
      let substringForMatch = muStr.substring(with: NSMakeRange(startIndex,matchRange.length))
      
      let replaceStr: String = self.hasURLPlaceholder == false ? substringForMatch : "    \(self.urlPlaceholder)"
      
      self.attributedText.replaceCharacters(in: NSMakeRange(startIndex, matchRange.length), with: replaceStr)
      
      let range = NSMakeRange(startIndex, replaceStr.count)
      
      self.attributedText.addAttribute(.foregroundColor, value: self.urlColor , range: range)
      
      if self.urlUnderLine {
        
        self.attributedText.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: range)
      }
      
      let str = String(format: "U%@{%@}", substringForMatch , NSValue(range: range))
      self.attributedText.addAttribute(NSAttributedString.Key(rawValue: "keyAttribute"), value: str , range: range)
      forIndex += substringForMatch.count - replaceStr.count
    }
    
  }
  
  func runsNumber() {
    
    let muStr = self.attributedText.mutableString
    let regular = "\\d{3}-\\d{8}|\\d{3}-\\d{7}|\\d{4}-\\d{8}|\\d{4}-\\d{7}|1+[358]+\\d{9}|\\d{8}|\\d{7}"
    guard let regex = try? NSRegularExpression(pattern: regular, options: .caseInsensitive ) else { return }
    let satches = regex.matches(in: muStr as String, options: .reportProgress , range: NSMakeRange(0,muStr.length))
    
    for match in satches {
      
      let matchRange = match.range
      let substringForMatch = muStr.substring(with: matchRange)
      self.attributedText.addAttribute(.foregroundColor, value: self.numberColor , range: matchRange)
      let str = String(format: "T%@{%@}", substringForMatch , NSValue(range: matchRange))
      self.attributedText.addAttribute(NSAttributedString.Key(rawValue: "keyAttribute"), value: str , range: matchRange)
    }
    
  }
  
  func runsSomeone() {
    
    let mutableString = self.attributedText.mutableString
    let regular = "@[^\\s@]+?\\s{1}"
    guard let regex = try? NSRegularExpression(pattern: regular, options: .caseInsensitive ) else { return }
    let matches = regex.matches(in: mutableString as String, options: .reportProgress , range: NSMakeRange(0, mutableString.length))
    
    for match in matches {
      
      let matchRange = match.range
      let substringForMatch = mutableString.substring(with: matchRange)
      self.attributedText.addAttribute(.foregroundColor, value: self.atSomeOneColor , range: matchRange)
      let str = String(format: "A%@{%@}", substringForMatch , NSValue(range: matchRange))
      self.attributedText.addAttribute(NSAttributedString.Key(rawValue: "keyAttribute"), value: str , range: matchRange)
      
    }
    
  }
  
}

// MARK: - Utility
private extension TextModel {
  
  mutating func update() {
    
    let font = self.font
    let fontSpace = self.fontSpace
    var lineSpace = self.lineSpace
    
    let attributedText = NSMutableAttributedString(string: self.text)
    
    attributedText.addAttribute(.font, value: font, range: NSMakeRange(0, attributedText.length))
    
    attributedText.addAttribute(.foregroundColor , value: self.textColor , range: NSMakeRange(0, attributedText.length))
    
    attributedText.addAttribute(.kern, value: fontSpace, range: NSMakeRange(0, attributedText.length))
    
    // 添加换行模式
    var lineBreakModel: CTLineBreakMode = .byCharWrapping
    let lineBreakStyle = CTParagraphStyleSetting(spec: .lineBreakMode , valueSize: MemoryLayout<CTLineBreakMode>.size, value: &lineBreakModel)
    
    // 行距
    let lineSpaceStyle = CTParagraphStyleSetting(spec: CTParagraphStyleSpecifier.lineSpacingAdjustment, valueSize: 4, value: &lineSpace)
    //let lineSpaceStyle = CTParagraphStyleSetting(spec: .lineSpacingAdjustment, valueSize: sizeof(CGFloat()), value: &lineSpace)
    
    let settings = [lineBreakStyle,lineSpaceStyle]
    let style = CTParagraphStyleCreate(settings, settings.count )
    attributedText.addAttributes([NSAttributedString.Key(rawValue: kCTParagraphStyleAttributeName as String) : style], range: NSMakeRange(0, attributedText.length))
    
    self.attributedText = attributedText
    
    self.runsURL()
    self.runsNumber()
    self.runsSomeone()
  }
  
}




