//
//  ArcTextView.swift
//  ComponentKit
//
//  Created by William Lee on 11/03/2018.
//  Copyright © 2018 William Lee. All rights reserved.
//

import UIKit

public class ArcTextView: UIView {
  
  /// 文字内容
  public var text: String = "" {
    
    didSet { self.setNeedsDisplay() }
  }
  /// 文字属性
  public var textAttributes: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 14), .backgroundColor: UIColor.clear] {
    
    didSet { self.setNeedsDisplay() }
  }
  /// 文字对齐方式
  public var textAlignment: NSTextAlignment = .center {
    
    didSet { self.setNeedsDisplay() }
  }
  /// 文字形成的扇形半径
  public var radius: CGFloat = 150 {
    
    didSet { self.setNeedsDisplay() }
  }
  /// 文字描绘的基础角度
  public var baseAngle: CGFloat = -90 * CGFloat.pi / 180 {
    
    didSet { self.setNeedsDisplay() }
  }
  /// 文字间距
  public var characterSpacing: CGFloat = 1 {
    
    didSet { self.setNeedsDisplay() }
  }
  
  /// 上曲、下曲
  public var isUp: Bool = false {
    
    didSet { self.setNeedsLayout() }
  }
  
  private var circleCenterPoint: CGPoint = .zero
  
  /// 是否开启参考线模式
  private var isDebug: Bool = false
  
  public override init(frame: CGRect) {
    super.init(frame: frame)
    
    self.backgroundColor = UIColor.clear
  }
  
  required public init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override public func layoutSubviews() {
    super.layoutSubviews()
    
    self.circleCenterPoint = CGPoint(x: self.bounds.midX, y: self.bounds.midY)
    self.setNeedsDisplay()
  }
  
  // Only override draw() if you perform custom drawing.
  // An empty implementation adversely affects performance during animation.
  override public func draw(_ rect: CGRect) {

    //Get the string size.
    let stringSize: CGSize = NSAttributedString(string: self.text, attributes: self.textAttributes).size()
    
    //If the radius not set, calculate the maximum radius.
    var radius: CGFloat =  self.radius
    if radius <= 0 {
      
      radius = min(self.bounds.width, self.bounds.height)/2 - stringSize.height
    }
    
    //Calculate the angle per charater.
    self.characterSpacing = (self.characterSpacing > 0) ? self.characterSpacing : 1;
    let circumference: CGFloat = radius * CGFloat.pi * 2
    let anglePerPixel: CGFloat = CGFloat.pi * 2 / circumference * self.characterSpacing
    
    //Set initial angle.
    var startAngle: CGFloat = 0
    if self.textAlignment == .right {
      
      startAngle = self.baseAngle - (stringSize.width * anglePerPixel)
      
    } else if self.textAlignment == .left {
      
      startAngle = self.baseAngle
      
    } else {
      
      startAngle = self.baseAngle - (stringSize.width * anglePerPixel / 2)
    }
    
    // 上下翻转
    if self.isUp {
      
      startAngle = -startAngle
    }
    
    //Set drawing context.
    guard let context = UIGraphicsGetCurrentContext() else { return }

    //Set helper vars.
    var characterPosition: CGFloat = 0
    var lastCharacter: String?
    self.text.forEach({ (char) in
      
      //Set current character.
      let currentCharacter = String(char)
      
      //Set currenct character size & kerning.
      let stringSize: CGSize = NSAttributedString(string: currentCharacter, attributes: self.textAttributes).size()
      let kerning: CGFloat = self.kerningForCharacter(currentCharacter: currentCharacter, previousCharacter: lastCharacter)
      
      //Add half of character width to characterPosition, substract kerning.
      characterPosition += (stringSize.width / 2) - kerning;
      
      //Calculate character Angle
      var angle: CGFloat = characterPosition * anglePerPixel
      if self.isUp {
        
        angle = startAngle - angle
        
      } else {
        
        angle = startAngle + angle
      }
      //Calculate character drawing point.
      var characterPoint: CGPoint = CGPoint(x: radius * cos(angle) + self.circleCenterPoint.x, y: radius * sin(angle) + self.circleCenterPoint.y)
      if self.isUp {
        
        characterPoint.y -= self.circleCenterPoint.y
        
      } else {
        
        characterPoint.y += self.circleCenterPoint.y
      }
      //Strings are always drawn from top left. Calculate the right pos to draw it on bottom center.
      let stringPoint: CGPoint = CGPoint(x: characterPoint.x - stringSize.width / 2.0 , y: characterPoint.y - stringSize.height)

      //Save the current context and do the character rotation magic.
      context.saveGState()

      context.ctm.translatedBy(x: characterPoint.x, y: characterPoint.y)
      let textTransform: CGAffineTransform = CGAffineTransform(rotationAngle: angle + CGFloat.pi / 2.0)
      context.ctm.concatenating(textTransform)
      context.ctm.translatedBy(x: -characterPoint.x, y: -characterPoint.y)
      
      //Draw the character
      NSAttributedString(string: currentCharacter, attributes: self.textAttributes).draw(at: stringPoint)
      
      //If we need some visual debugging, draw the visuals.
      self.showCharacterBoundingBox(withString: stringPoint, characterPoint: characterPoint, size: stringSize)
      //Restore context to make sure the rotation is only applied to this character.
      context.restoreGState()
      //Add the other half of the character size to the character position.
      characterPosition += stringSize.width / 2
      //Stop if we've reached one full circle.
      if characterPosition * anglePerPixel >= CGFloat.pi * 2 { return }
      //store the currentCharacter to use in the next run for kerning calculation.
      lastCharacter = currentCharacter
    })
    
    //If we need some visual debugging, draw the circle.
    self.showCircle(with: radius)
    
  }
  
  
}

// MARK: - Utility
private extension ArcTextView {
  
  func kerningForCharacter(currentCharacter: String, previousCharacter: String?) -> CGFloat {
    
    guard let previousCharacter = previousCharacter else { return 0 }
    let totalSize = NSAttributedString(string: currentCharacter + previousCharacter, attributes: self.textAttributes).size().width
    let currentCharacterSize = NSAttributedString(string: currentCharacter, attributes: self.textAttributes).size().width
    let previousCharacterSize = NSAttributedString(string: previousCharacter, attributes: self.textAttributes).size().width
    
    return (currentCharacterSize + previousCharacterSize) - totalSize;
  }
  
}

// MARK: - Debug
private extension ArcTextView {
  
  func showCharacterBoundingBox(withString stringPoint: CGPoint, characterPoint: CGPoint, size: CGSize) {
    
    guard self.isDebug else { return }
    //Show Character BoundingBox
    UIColor(red: 1, green: 0, blue: 0, alpha: 0.5).setStroke()
    UIBezierPath(rect: CGRect(x: stringPoint.x, y: stringPoint.y, width: size.width, height: size.height)).stroke()
    
    //Show character point
    UIColor.blue.setStroke()
    UIBezierPath(arcCenter: characterPoint, radius: 1, startAngle: 0, endAngle: 0 * CGFloat.pi, clockwise: true).stroke()
  }
  
  func showCircle(with radius: CGFloat) {
    
    guard self.isDebug else { return }
    
    //Show Circle
    UIColor.green.setStroke()
    UIBezierPath(arcCenter: self.circleCenterPoint, radius: radius, startAngle: 0, endAngle: CGFloat.pi * 2, clockwise: true).stroke()
    
    let line = UIBezierPath()
    line.move(to: CGPoint(x: self.circleCenterPoint.x, y: self.circleCenterPoint.y - radius))
    line.addLine(to: CGPoint(x: self.circleCenterPoint.x, y: self.circleCenterPoint.y + radius))
    line.move(to: CGPoint(x: self.circleCenterPoint.x - radius, y: self.circleCenterPoint.y))
    line.addLine(to: CGPoint(x: self.circleCenterPoint.x + radius, y: self.circleCenterPoint.y))
    line.stroke()
    
  }
  
}


















