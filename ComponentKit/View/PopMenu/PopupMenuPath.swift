//
//  PopupMenuPath.swift
//  VideoModule
//
//  Created by Hiu on 2018/6/6.
//  Copyright © 2018年 飞进科技. All rights reserved.
//

import UIKit

public enum PopupMenuArrowDirection : Int {
  
  case top = 0 //箭头朝上
  case bottom
  case left
  case right
  case none
}

class PopupMenuPath {
  
  public static func maskLayerWithRect(rect : CGRect,
                                     rectCorner : UIRectCorner,
                                     cornerRadius : CGFloat,
                                     arrowWidth : CGFloat,
                                     arrowHeight : CGFloat,
                                     arrowPosition : CGFloat,
                                     arrowDirection : PopupMenuArrowDirection ) -> CAShapeLayer
  {
    let shapeLayer = CAShapeLayer.init()
    shapeLayer.path = bezierPathWithRect(myRect: rect, rectCorner: rectCorner, cornerRadius: cornerRadius, borderWidth: 0, borderColor: nil, backgroundColor: nil, arrowWidth: arrowWidth, arrowHeight: arrowHeight, myArrowPosition: arrowPosition, arrowDirection: arrowDirection).cgPath
    return shapeLayer
  }
  
  public static  func bezierPathWithRect(myRect : CGRect,
                                       rectCorner : UIRectCorner,
                                       cornerRadius : CGFloat,
                                       borderWidth : CGFloat,
                                       borderColor : UIColor?,
                                       backgroundColor : UIColor?,
                                       arrowWidth : CGFloat,
                                       arrowHeight : CGFloat,
                                       myArrowPosition : CGFloat,
                                       arrowDirection : PopupMenuArrowDirection ) -> UIBezierPath
  {
    let bezierPath = UIBezierPath.init()
    
    if let borderColor = borderColor {
      borderColor.setStroke()
    }
    if let backgroundColor = backgroundColor {
      backgroundColor.setFill()
    }
    bezierPath.lineWidth = borderWidth
    
    let rect = CGRect.init(x: borderWidth / 2, y: borderWidth / 2, width: myRect.width - borderWidth, height: myRect.height - borderWidth)
    
    var topRightRadius : CGFloat = 0
    var topLeftRadius : CGFloat = 0
    var bottomRightRadius : CGFloat = 0
    var bottomLeftRadius : CGFloat = 0
    
    var topRightArcCenter : CGPoint = CGPoint.zero
    var topLeftArcCenter : CGPoint = CGPoint.zero
    var bottomRightArcCenter : CGPoint = CGPoint.zero
    var bottomLeftArcCenter : CGPoint = CGPoint.zero
    
    if rectCorner.contains(UIRectCorner.topLeft) {
      topLeftRadius = cornerRadius
    }
    if rectCorner.contains(UIRectCorner.topRight) {
      topRightRadius = cornerRadius
    }
    if rectCorner.contains(UIRectCorner.bottomLeft) {
      bottomLeftRadius = cornerRadius
    }
    if rectCorner.contains(UIRectCorner.bottomRight) {
      bottomRightRadius = cornerRadius
    }
    
    
    if arrowDirection == .top {
      topLeftArcCenter = CGPoint.init(x: topLeftRadius + rect.minX, y: arrowHeight + topLeftRadius + rect.minX)
      topRightArcCenter = CGPoint.init(x: rect.width - topRightRadius + rect.minX, y: arrowHeight + topRightRadius + rect.minX)
      bottomLeftArcCenter = CGPoint.init(x: bottomLeftRadius + rect.minX, y: rect.height - bottomLeftRadius + rect.minX)
      bottomRightArcCenter = CGPoint.init(x: rect.width - bottomRightRadius + rect.minX, y: rect.height - bottomRightRadius + rect.minX)
      var arrowPosition : CGFloat = 0
      if myArrowPosition < topLeftRadius + arrowWidth / 2 {
        arrowPosition = topLeftRadius + arrowWidth / 2
      }else if myArrowPosition > rect.width - topRightRadius - arrowWidth / 2 {
        arrowPosition = rect.width - topRightRadius - arrowWidth / 2
      }else{
        arrowPosition = myArrowPosition
      }
      
      bezierPath.move(to: CGPoint.init(x: arrowPosition - arrowWidth / 2, y: arrowHeight + rect.minX))
      bezierPath.addLine(to: CGPoint.init(x: arrowPosition, y: rect.minY + rect.minX))
      bezierPath.addLine(to: CGPoint.init(x: arrowPosition + arrowWidth / 2, y: arrowHeight + rect.minX))
      bezierPath.addLine(to: CGPoint.init(x: rect.width - topRightRadius, y: arrowHeight + rect.minX))
      bezierPath.addArc(withCenter: topRightArcCenter, radius: topRightRadius, startAngle: CGFloat.pi * 3 / 2, endAngle: CGFloat.pi * 2, clockwise: true)
      bezierPath.addLine(to: CGPoint.init(x: rect.width + rect.minX, y: rect.height - bottomRightRadius - rect.minX))
      bezierPath.addArc(withCenter: bottomRightArcCenter, radius: bottomRightRadius, startAngle: 0, endAngle: CGFloat.pi*0.5, clockwise: true)
      bezierPath.addLine(to: CGPoint.init(x: bottomLeftRadius + rect.minX, y: rect.height + rect.minX))
      
      bezierPath.addArc(withCenter: bottomLeftArcCenter, radius: bottomLeftRadius, startAngle: CGFloat.pi*0.5, endAngle: CGFloat.pi, clockwise: true)
      bezierPath.addLine(to: CGPoint.init(x: rect.minX, y: arrowHeight + topLeftRadius + rect.minX))
      bezierPath.addArc(withCenter: topLeftArcCenter, radius: topLeftRadius, startAngle: CGFloat.pi, endAngle: CGFloat.pi * 3 / 2, clockwise: true)
    }else if arrowDirection == .bottom {// 箭头朝下
      
      topLeftArcCenter = CGPoint.init(x: topLeftRadius + rect.minX, y: topLeftRadius + rect.minX)
      topRightArcCenter = CGPoint.init(x: rect.width - topRightRadius + rect.minX, y: topRightRadius + rect.minX)
      bottomLeftArcCenter = CGPoint.init(x: bottomLeftRadius + rect.minX, y: rect.height - bottomLeftRadius + rect.minX - arrowHeight)
      bottomRightArcCenter = CGPoint.init(x: rect.width - bottomRightRadius + rect.minX, y: rect.height - bottomRightRadius + rect.minX - arrowHeight)
      var arrowPosition : CGFloat = 0
      if myArrowPosition < bottomLeftRadius + arrowWidth / 2 {
        arrowPosition = bottomLeftRadius + arrowWidth / 2
      }else if arrowPosition > rect.width - bottomRightRadius - arrowWidth / 2 {
        arrowPosition = rect.width - bottomRightRadius - arrowWidth / 2
      }else{
        arrowPosition = myArrowPosition
      }
      
      bezierPath.move(to: CGPoint.init(x: arrowPosition + arrowWidth / 2, y: rect.height - arrowHeight + rect.minX))
      bezierPath.addLine(to: CGPoint.init(x: arrowPosition, y: rect.height + rect.minX))
      bezierPath.addLine(to: CGPoint.init(x: arrowPosition - arrowWidth / 2, y: rect.height - arrowHeight + rect.minX))
      bezierPath.addLine(to: CGPoint.init(x: bottomLeftRadius + rect.minX, y: rect.height - arrowHeight + rect.minX))
      bezierPath.addArc(withCenter: bottomLeftArcCenter, radius: bottomLeftRadius, startAngle: CGFloat.pi / 2, endAngle: CGFloat.pi, clockwise: true)
      bezierPath.addLine(to: CGPoint.init(x: rect.minX, y: topLeftRadius + rect.minX))
      bezierPath.addArc(withCenter: topLeftArcCenter, radius: topLeftRadius, startAngle: CGFloat.pi, endAngle: CGFloat.pi * 3 / 2, clockwise: true)
      bezierPath.addLine(to: CGPoint.init(x: rect.width - topRightRadius + rect.minX, y: rect.minX))
      bezierPath.addArc(withCenter: topRightArcCenter, radius: topRightRadius, startAngle: CGFloat.pi * 3 / 2, endAngle: CGFloat.pi * 2, clockwise: true)
      bezierPath.addLine(to: CGPoint.init(x: rect.width + rect.minX, y: rect.height - bottomRightRadius - rect.minX - arrowHeight))
      bezierPath.addArc(withCenter: bottomRightArcCenter, radius: bottomRightRadius, startAngle: 0, endAngle: CGFloat.pi / 2, clockwise: true)
    }else if arrowDirection == .left { // 箭头朝左
      
      topLeftArcCenter = CGPoint.init(x: topLeftRadius + rect.minX + arrowHeight, y: topLeftRadius + rect.minX)
      topRightArcCenter = CGPoint.init(x: rect.width - topRightRadius + rect.minX, y: topRightRadius + rect.minX)
      bottomLeftArcCenter = CGPoint.init(x: bottomLeftRadius + rect.minX + arrowHeight, y: rect.height - bottomLeftRadius + rect.minX)
      bottomRightArcCenter = CGPoint.init(x: rect.width - bottomRightRadius + rect.minX, y: rect.height - bottomRightRadius + rect.minX)
      
      var arrowPosition : CGFloat = 0
      if myArrowPosition < topLeftRadius + arrowWidth / 2 {
        arrowPosition = topLeftRadius + arrowWidth / 2
      }else if arrowPosition > rect.height - bottomLeftRadius - arrowWidth / 2 {
        arrowPosition = rect.height - bottomLeftRadius - arrowWidth / 2
      }else{
        arrowPosition = myArrowPosition
      }
      
      bezierPath.move(to: CGPoint.init(x: arrowHeight + rect.minX, y: arrowPosition + arrowWidth / 2))
      bezierPath.addLine(to: CGPoint.init(x: rect.minX, y: arrowPosition))
      bezierPath.addLine(to: CGPoint.init(x: arrowHeight + rect.minX, y: arrowPosition - arrowWidth / 2))
      bezierPath.addLine(to: CGPoint.init(x: arrowHeight + rect.minX, y: topLeftRadius + rect.minX))
      bezierPath.addArc(withCenter: topLeftArcCenter, radius: topLeftRadius, startAngle: CGFloat.pi, endAngle: CGFloat.pi*3/2, clockwise: true)
      bezierPath.addLine(to: CGPoint.init(x: rect.width - topRightRadius, y: rect.minX))
      bezierPath.addArc(withCenter: topRightArcCenter, radius: topRightRadius, startAngle: CGFloat.pi*3/2, endAngle: CGFloat.pi*2, clockwise: true)
      bezierPath.addLine(to: CGPoint.init(x: rect.width + rect.minX, y: rect.height - bottomRightRadius - rect.minX))
      bezierPath.addArc(withCenter: bottomRightArcCenter, radius: bottomRightRadius, startAngle: 0, endAngle: CGFloat.pi*0.5, clockwise: true)
      bezierPath.addLine(to: CGPoint.init(x: arrowHeight + bottomLeftRadius + rect.minX, y: rect.height + rect.minX))
      bezierPath.addArc(withCenter: bottomLeftArcCenter, radius: bottomLeftRadius, startAngle: CGFloat.pi*0.5, endAngle: CGFloat.pi, clockwise: true)
    }else if arrowDirection == .right{ // 箭头朝右
      
      topLeftArcCenter = CGPoint.init(x: topLeftRadius + rect.minX, y: topLeftRadius + rect.minX)
      topRightArcCenter = CGPoint.init(x: rect.width - topRightRadius + rect.minX - arrowHeight, y: topRightRadius + rect.minX)
      bottomLeftArcCenter = CGPoint.init(x: bottomLeftRadius + rect.minX , y: rect.height - bottomLeftRadius + rect.minX)
      bottomRightArcCenter = CGPoint.init(x: rect.width - bottomRightRadius + rect.minX - arrowHeight, y: rect.height - bottomRightRadius + rect.minX)
      
      var arrowPosition : CGFloat = 0
      if myArrowPosition < topRightRadius + arrowWidth / 2 {
        arrowPosition = topRightRadius + arrowWidth / 2
      }else if arrowPosition > rect.height - bottomRightRadius - arrowWidth / 2 {
        arrowPosition = rect.height - bottomRightRadius - arrowWidth / 2
      }else{
        arrowPosition = myArrowPosition
      }
      
      bezierPath.move(to: CGPoint.init(x: rect.width - arrowHeight + rect.minX, y: arrowPosition - arrowWidth / 2))
      bezierPath.addLine(to: CGPoint.init(x: rect.width + rect.minX, y: arrowPosition))
      bezierPath.addLine(to: CGPoint.init(x: rect.width - arrowHeight + rect.minX, y: arrowPosition + arrowWidth / 2))
      
      bezierPath.addLine(to: CGPoint.init(x: rect.width - arrowHeight + rect.minX, y: rect.height - bottomRightRadius - rect.minX))
      bezierPath.addArc(withCenter: bottomRightArcCenter, radius: bottomRightRadius, startAngle: 0, endAngle: CGFloat.pi/2, clockwise: true)
      bezierPath.addLine(to: CGPoint.init(x: bottomLeftRadius + rect.minX, y: rect.height + rect.minX))
      bezierPath.addArc(withCenter: bottomLeftArcCenter, radius: bottomLeftRadius, startAngle: CGFloat.pi/2, endAngle: CGFloat.pi, clockwise: true)
      bezierPath.addLine(to: CGPoint.init(x: rect.minX, y: arrowHeight + topLeftRadius + rect.minX))
      bezierPath.addArc(withCenter: topLeftArcCenter, radius: topLeftRadius, startAngle: CGFloat.pi, endAngle: CGFloat.pi*0.5*3, clockwise: true)
      bezierPath.addLine(to: CGPoint.init(x: rect.width - topRightRadius + rect.minX - arrowHeight, y: rect.minX))
      bezierPath.addArc(withCenter: topRightArcCenter, radius: topRightRadius, startAngle: CGFloat.pi*0.5*3, endAngle: CGFloat.pi*2, clockwise: true)
    }else if arrowDirection == .none{ // 无箭头
      
      topLeftArcCenter = CGPoint.init(x: topLeftRadius + rect.minX, y: topLeftRadius + rect.minX)
      topRightArcCenter = CGPoint.init(x: rect.width - topRightRadius + rect.minX, y: topRightRadius + rect.minX)
      bottomLeftArcCenter = CGPoint.init(x: bottomLeftRadius + rect.minX , y: rect.height - bottomLeftRadius + rect.minX)
      bottomRightArcCenter = CGPoint.init(x: rect.width - bottomRightRadius + rect.minX, y: rect.height - bottomRightRadius + rect.minX)
      
      
      bezierPath.move(to: CGPoint.init(x: topLeftRadius + rect.minX, y: rect.minX))
      bezierPath.addLine(to: CGPoint.init(x: rect.width - topRightRadius, y: rect.minX))
      
      bezierPath.addArc(withCenter: topRightArcCenter, radius: topRightRadius, startAngle: CGFloat.pi*0.5*3, endAngle: CGFloat.pi*2, clockwise: true)
      
      bezierPath.addLine(to: CGPoint.init(x: rect.width + rect.minX, y: rect.height - bottomRightRadius - rect.minX))
      
      bezierPath.addArc(withCenter: bottomRightArcCenter, radius: bottomRightRadius, startAngle: 0, endAngle: CGFloat.pi/2, clockwise: true)
      
      bezierPath.addLine(to: CGPoint.init(x: bottomLeftRadius + rect.minX, y: rect.height + rect.minX))
      
      bezierPath.addArc(withCenter: bottomLeftArcCenter, radius: bottomLeftRadius, startAngle: CGFloat.pi/2, endAngle: CGFloat.pi, clockwise: true)
      
      bezierPath.addLine(to: CGPoint.init(x: rect.minX , y: arrowHeight + topLeftRadius + rect.minX))
      bezierPath.addArc(withCenter: topLeftArcCenter, radius: topLeftRadius, startAngle: CGFloat.pi, endAngle: CGFloat.pi*3/2, clockwise: true)
    }
    bezierPath.close()
    return bezierPath
  }
  
}
