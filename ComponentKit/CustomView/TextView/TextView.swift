//
//  TextView.swift
//  ComponentKit
//
//  Created by William Lee on 22/03/2018.
//  Copyright © 2018 William Lee. All rights reserved.
//

import UIKit

public class TextView: UIView {
  
  /// 文本
  @IBInspectable public var text: String = "" {
    
    didSet {
      
      self.textModel.text = self.text
      self.invalidateIntrinsicContentSize()
      self.setNeedsDisplay()
    }
    
  }
  
  public var textModel = TextModel()
  
  private var urlHandle: URLTapHandle?
  private var telephoneHandle: TelephoneTapHandle?
  private var otherHandle:  OtherTapHandle?
  
  private var keyRectArr: [NSValue: String] = [:]
  private var keyAttributeArr: [String: String] = [:]
  private var keyDatas: [String] = []
  private var firstRect: CGRect = .zero
  
  private var touchedRect: [CGRect] = []
  
  public override var intrinsicContentSize: CGSize {
    
    let contentHeight = self.textModel.height(rectSize: CGSize(width: self.bounds.width, height: 10000))
    return CGSize(width: UIView.noIntrinsicMetric, height: contentHeight)
  }
  
  public override func layoutSubviews() {
    super.layoutSubviews()
    // 通知系统更新内建大小
    self.invalidateIntrinsicContentSize()
  }
  
  public override func draw(_ rect: CGRect) {
    super.draw(rect)
    
    self.keyRectArr.removeAll()
    self.keyAttributeArr.removeAll()
    self.keyDatas.removeAll()
    
    let font = self.textModel.font
    let lineSpace = self.textModel.lineSpace
    let highlightBackgroundRadius = self.textModel.highlightBackgroundRadius
    let highlightBackgroundColor = self.textModel.highlightBackgroundColor
    let attributedText = self.textModel.attributedText
    
    // 绘图
    guard let context = UIGraphicsGetCurrentContext() else { return }
    context.setStrokeColor((self.backgroundColor?.cgColor)!)
    context.textMatrix = CGAffineTransform.identity
    context.translateBy(x: 0, y: self.bounds.height)
    context.scaleBy(x: 1, y: -1)
    
    //创建一个用来描画文字的路径，其区域为当前视图的bounds  CGPath
    let path = CGMutablePath()
    path.addRect(self.bounds)
    
    // 创建framesetter及其管理的frame 是描画文字的一个视图范围 CTFrame
    let framesetter: CTFramesetter = CTFramesetterCreateWithAttributedString(attributedText as CFAttributedString)
    let frame: CTFrame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, nil)
    
    let lines: CFArray = CTFrameGetLines(frame)
    let lineCount: CFIndex = CFArrayGetCount(lines)
    
    var lineOrigins: [CGPoint] = Array(repeating: CGPoint.zero, count:lineCount)
    CTFrameGetLineOrigins(frame, CFRangeMake(0, 0), &lineOrigins)
    
    // 绘制高亮区域
    if self.touchedRect.count != 0 {
      
      for rect in self.touchedRect {
        
        let path = UIBezierPath(roundedRect: rect, cornerRadius: highlightBackgroundRadius).cgPath
        context.setFillColor(highlightBackgroundColor.cgColor)
        context.addPath(path)
        context.fillPath()
      }
    }
    
    // ================================= 分割线 =====================================
    var frameY: CGFloat = 0
    let lineHeight = CGFloat(font.lineHeight + lineSpace)
    var prevImgRect: CGRect = .zero
    for lineIndex in 0 ..< lineCount {
      
      let line = unsafeBitCast(CFArrayGetValueAtIndex(lines, lineIndex), to: CTLine.self)
      // 获得行首的CGPoint
      var lineOrigin = lineOrigins[lineIndex]
      
      frameY = self.bounds.height - CGFloat(lineIndex + 1) * lineHeight - font.descender
      lineOrigin.y = frameY
      
      context.textPosition = lineOrigin
      CTLineDraw(line, context)
      
      let runs = CTLineGetGlyphRuns(line)
      
      for runIndex in 0 ..< CFArrayGetCount(runs) {
        
        let run = unsafeBitCast(CFArrayGetValueAtIndex(runs, runIndex),to: CTRun.self)
        
        var runAscent: CGFloat = 0
        var runDescent: CGFloat = 0
        var runRect: CGRect = .zero
        runRect.origin.x = lineOrigin.x + CTLineGetOffsetForStringIndex(line, CTRunGetStringRange(run).location, nil)
        runRect.origin.y = lineOrigin.y
        runRect.size.width = CGFloat(CTRunGetTypographicBounds(run, CFRangeMake(0, 0), &runAscent, &runDescent, nil))
        runRect.size.height = runAscent + runDescent
        
        let attributes = CTRunGetAttributes(run) as? [String: Any] //NSDictionary
        guard let keyAttribute = attributes?["keyAttribute"] as? String else { continue } // attributes.object(forKey: "keyAttribute") as? String
        
        let runWidth = CGFloat(CTRunGetTypographicBounds(run, CFRangeMake(0, 0), &runAscent, &runDescent, nil))
        let runPointX = runRect.origin.x + lineOrigin.x
        let runPointY = lineOrigin.y - self.textModel.faceOffset
        
        var keyRect: CGRect = .zero
        
        if keyAttribute.first == "U" && self.textModel.hasURLPlaceholder {
          
          if self.keyDatas.contains(keyAttribute) == false {
            
            self.keyDatas.append(keyAttribute)
            
            self.firstRect.origin.x = runPointX
            self.firstRect.origin.y = runPointY - (lineHeight + self.textModel.highlightBackgroundAdjustHeight - lineSpace) / 4 - self.textModel.highlightBackgroundOffset
            self.firstRect.size.width = runWidth
            self.firstRect.size.height = lineHeight + self.textModel.highlightBackgroundAdjustHeight
            
            // url
            prevImgRect.origin.x = runPointX + 2
            prevImgRect.origin.y = lineOrigin.y - ((lineHeight - self.textModel.tagImgSize.height) / 4)
            prevImgRect.size.width = self.textModel.tagImgSize.width
            prevImgRect.size.height = self.textModel.tagImgSize.height
            
            if let image = Assets.hyperlinkImage.cgImage {
              
              context.draw(image, in: prevImgRect)
            }
            
          } else {
            
            let tmpRect = CGRect(x: runPointX, y: runPointY-(lineHeight + self.textModel.highlightBackgroundAdjustHeight - lineSpace) / 4 - self.textModel.highlightBackgroundOffset, width: runWidth, height: lineHeight + self.textModel.highlightBackgroundAdjustHeight)
            
            if self.firstRect != .zero {
              
              if abs(tmpRect.origin.y - self.firstRect.origin.y) > 5 {
                
                // 如果图片恰好没有到行末尾
                self.keyRectArr[NSValue(cgRect: self.firstRect)] = keyAttribute
                self.keyRectArr[NSValue(cgRect: tmpRect)] = keyAttribute
                
              } else {
                
                keyRect = CGRect(x: self.firstRect.origin.x , y: self.firstRect.origin.y, width: self.firstRect.width + runWidth, height: self.firstRect.height)
              }
              self.firstRect = .zero
              
            } else {
              
              keyRect = tmpRect
            }
            self.keyRectArr[NSValue(cgRect:keyRect)] = keyAttribute
          }
          
        } else {
          
          keyRect.origin.x = runPointX
          keyRect.origin.y = runPointY - (lineHeight + self.textModel.highlightBackgroundAdjustHeight - lineSpace) / 4 - self.textModel.highlightBackgroundOffset
          keyRect.size.width = runWidth
          keyRect.size.height = lineHeight + self.textModel.highlightBackgroundAdjustHeight
          self.keyRectArr[NSValue(cgRect: keyRect)] = keyAttribute
        }
        
      }
      
    }
  }
  
  public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesBegan(touches, with: event)
    
    //touches.forEach({ $0.location(in: self) })
    guard let location = touches.first?.location(in: self) else { return }
    let runLocation = CGPoint(x: location.x, y: self.frame.size.height - location.y)
    
    self.touchedRect.removeAll()
    for (key, _) in self.keyRectArr {
      
      guard key.cgRectValue.contains(runLocation) else { continue }
      self.touchedRect.append(key.cgRectValue)
    }
    self.setNeedsDisplay()
    
  }
  
  public override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesCancelled(touches, with: event)
    
    self.keyRectArr.removeAll()
    self.touchedRect.removeAll()
    self.setNeedsDisplay()
  }
  
  public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesEnded(touches, with: event)
    
    guard let location = touches.first?.location(in: self) else { return }
    let runLocation = CGPoint(x: location.x, y: self.frame.size.height - location.y)
    // 遍历 rect
    for (k, v) in self.keyRectArr {
      
      let rect = k.cgRectValue
      guard rect.contains(runLocation) else { continue }
      guard self.touchedRect.contains(rect), let temp = v.components(separatedBy: "{").first?.substringFromIndex(index: 1) else { continue }
      
      self.performHandle(with: v, and: temp)
      
    }
    
    guard self.touchedRect.count > 0 else { return }
    self.keyRectArr.removeAll()
    self.touchedRect.removeAll()
    self.setNeedsDisplay()
  }
  
}

// MARK: - Public
public extension TextView {
  
  typealias URLTapHandle = (URL) -> Void
  typealias TelephoneTapHandle = (String) -> Void
  typealias OtherTapHandle = (String) -> Void
  func setupTapHandle(url: URLTapHandle?, telephone: TelephoneTapHandle?, other: OtherTapHandle?) {
    
    self.urlHandle = url
    self.telephoneHandle = telephone
    self.otherHandle = other
  }
  
}

// MARK: - Utility
private extension TextView {
  
  func performHandle(with v: String, and content: String) {
    
    if v.hasPrefix("U") {
      
      // url
      var url = content
      if url.hasPrefix("http") == false { url = "https://\(url)" }
      self.urlHandle?(URL(string: url)!)
      
    } else if v.hasPrefix("T"){
      
      let tel = content
      self.telephoneHandle?(tel)
      
    } else if v.hasPrefix("A") {
      
      let someOne = content
      self.otherHandle?(someOne)
      
    } else {
      
      // TODO: - 其他类型
    }
  }
  
}

extension String {
  
  /**
   substringFromIndex  int版本
   
   - parameter index: 开始下标
   
   - returns: 截取后的字符串
   */
  fileprivate func substringFromIndex(index: Int) -> String {
    
    let startIndex = self.index(self.startIndex, offsetBy: index)
    
    return String(self[startIndex...])
  }
  
  /**
   substringToIndex int版本
   
   - parameter index: 介绍下标
   
   - returns: 截取后的字符串
   */
  fileprivate func substringToIndex(index: Int) -> String {
    
    let endIndex = self.index(self.startIndex, offsetBy: index)
    
    return String(self[self.startIndex..<endIndex])
  }
  
  /**
   substringWithRange int版本
   
   - parameter start: 开始下标
   - parameter end:   结束下标
   
   - returns: 截取后的字符串
   */
  fileprivate func substringWithRange(start: Int, end: Int) -> String{
    
    let startIndex = self.index(self.startIndex, offsetBy: start)
    let endIndex = self.index(self.startIndex, offsetBy: end)
    return String(self[startIndex ..< endIndex])
  }
  
  
}


public class Assets {
  
  public class var hyperlinkImage: UIImage { return Assets.bundledImage(named: "hyperlink") }
  
  internal class func bundledImage(named name: String) -> UIImage {
    
    let bundle = Bundle.main
    
    return UIImage(named: name, in: bundle, compatibleWith: nil) ?? UIImage()
  }
  
}







