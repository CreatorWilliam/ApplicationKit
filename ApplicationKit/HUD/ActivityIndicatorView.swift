//
//  ActivityIndicatorView.swift
//  IntellectiveTrainingPlatform
//
//  Created by Hiu on 2019/1/31.
//  Copyright © 2019 广州飞进信息科技有限公司. All rights reserved.
//

import UIKit

public class ActivityIndicatorView: UIView {
  
  /// 动画是否在进行
  private(set) public var isAnimatiing: Bool = false
  
  /// 是否传递交互事件
  public var canTouchOnSuperView: Bool = true {
    
    didSet {
      
      self.isUserInteractionEnabled = !canTouchOnSuperView
    }
  }
 
  /// 配置三个球的颜色
  public var layerTintColors = [UIColor(0x23F6EB), UIColor.black, UIColor(0xFF2E56)] {

    didSet {
      if oldValue != layerTintColors {

        self.animationLayer.sublayers?.enumerated().forEach({ (index, subLayer) in

          guard let layer = subLayer as? CAShapeLayer else { return }
          layer.strokeColor = layerTintColors[index].cgColor
          layer.fillColor = layerTintColors[index].cgColor

        })
      }
    }
  }
  
  /// 配置三个球范围的大小
  public var size: CGFloat = 40 {
    
    didSet {
      
      if oldValue != size {
        
        self.setupAnimation()
        self.invalidateIntrinsicContentSize()
      }
    }
  }
  
  private let animationLayer = CALayer()
  
  override init(frame: CGRect) {
    
    super.init(frame: frame)
    
    self.commonInit()
    self.backgroundColor = .clear
  }
  
  public init(with view: UIView) {
    
    super.init(frame: view.bounds)
    self.commonInit()
    self.backgroundColor = .clear
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override public var intrinsicContentSize: CGSize {
    
    return CGSize(width: self.size, height: self.size)
  }
  

  private func commonInit() {
    
    self.isUserInteractionEnabled = false
    self.isHidden = true
    self.animationLayer.frame = self.layer.bounds
    self.layer.addSublayer(self.animationLayer)
    
    /// 保证自己不被撑大
    self.setContentHuggingPriority(UILayoutPriority.required, for: NSLayoutConstraint.Axis.horizontal)
    self.setContentHuggingPriority(UILayoutPriority.required, for: NSLayoutConstraint.Axis.vertical)
  }
  
  private func setupAnimation() {
    
    self.animationLayer.sublayers = nil
    self.setupAnimation(self.animationLayer, size: CGSize(width: self.size, height: self.size), tintColors: self.layerTintColors)
    self.animationLayer.speed = 0.0

  }
}


// MARK: - Class Method
public extension ActivityIndicatorView {
  
  class func show(in view: UIView) -> ActivityIndicatorView {
    
    let activity = ActivityIndicatorView(with: view)
    view.addSubview(activity)
    return activity
  }
  
  class func hide(in view: UIView) {
    
    let subviewsEnum = view.subviews.reversed()
    subviewsEnum.forEach { (subView) in
      
      guard let activity = subView as? ActivityIndicatorView else { return }
      activity.hide(compelete: {})
    }
  }
}


// MARK: - Public
public extension ActivityIndicatorView {
  
  func stopAnimation() {
    
    self.animationLayer.speed = 0.0
    self.isAnimatiing = false
    self.isHidden = true
  }
  
  func startAnimation() {
    
    self.setupAnimation()
    self.isHidden = false
    self.animationLayer.speed = 1
    self.isAnimatiing = true
 
  }
  
  func hide(_ delay: TimeInterval = 0.0, compelete: @escaping () -> ()) {
    
    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delay, execute: {
      
      self.stopAnimation()
      compelete()
    })
  }
}


private extension ActivityIndicatorView {
  
  func setupAnimation(_ layer: CALayer, size: CGSize, tintColors: [UIColor]) {
    
    let beginTime = CACurrentMediaTime()
    let duration = 0.5
    
    let circleSize: CGFloat = size.width / 4.0
    let circlePadding: CGFloat = circleSize / 2.0
    
    let circleX: CGFloat = (layer.bounds.size.width - size.width) / 2.0
    let circleY: CGFloat = (layer.bounds.size.height - size.height) / 2.0
    
    /// 创建三个球layer
    (0 ..< 3).forEach { (i) in
      
      let circle = CALayer()
      circle.frame = CGRect(x: circleX + (circleSize + circlePadding) * CGFloat((i % 3)), y: circleY + (size.height - circleSize) / 2, width: circleSize, height: circleSize)
      circle.backgroundColor = tintColors[i].cgColor
      circle.anchorPoint = CGPoint(x: 0.5, y: 0.5)
      circle.opacity = 1.0
      circle.cornerRadius = circleSize * 0.5
      layer.addSublayer(circle)
    }
    
    let circle1 = layer.sublayers?[0]
    let circle2 = layer.sublayers?[1]
    let circle3 = layer.sublayers?[2]
    
    
    
    let circle1Color = tintColors[0]
    let circle2Color = tintColors[1]
    let circle3Color = tintColors[2]
    
    /// 第一个围绕着转的圆的中心
    let otherRoundCenter1 = CGPoint(x: circleX + circleSize + circlePadding * 0.5, y: layer.bounds.size.height * 0.5)
    /// 第二个围绕着转的圆的中心
    let otherRoundCenter2 = CGPoint(x: circleX + circleSize * 2 + circlePadding + circlePadding * 0.5, y: layer.bounds.size.height * 0.5)
    
    /// 绘制第一个球的圆的路径
    let path1 = UIBezierPath()
    path1.addArc(withCenter: otherRoundCenter1, radius: circleSize * 0.5 + circlePadding * 0.5, startAngle: -.pi, endAngle: 0, clockwise: true)
    let path1_other = UIBezierPath()
    path1_other.addArc(withCenter: otherRoundCenter2, radius: circleSize * 0.5 + circlePadding * 0.5, startAngle: -.pi, endAngle: 0, clockwise: false)
    path1.append(path1_other)
    self.movePathAnimation(circle1, path: path1, time: duration, beginTime: beginTime)
    self.colorAnimation(circle1, fromColor: circle1Color, toColor: circle3Color, time: duration)
    
    /// 绘制第二个球的圆的路径
    let path2 = UIBezierPath()
    path2.addArc(withCenter: otherRoundCenter1, radius: circleSize * 0.5 + circlePadding * 0.5, startAngle: 0, endAngle: -.pi, clockwise: true)
    self.movePathAnimation(circle2, path: path2, time: duration, beginTime: beginTime)
    self.colorAnimation(circle2, fromColor: circle2Color, toColor: circle1Color, time: duration)
    
    /// 绘制第三个球的圆的路径
    let path3 = UIBezierPath()
    path3.addArc(withCenter: otherRoundCenter2, radius: circleSize * 0.5 + circlePadding * 0.5, startAngle: 0, endAngle: -.pi, clockwise: false)
    self.movePathAnimation(circle3, path: path3, time: duration, beginTime: beginTime)
    self.colorAnimation(circle3, fromColor: circle3Color, toColor: circle2Color, time: duration)
  }
  
  func movePathAnimation(_ layer: CALayer?, path: UIBezierPath, time: Double, beginTime: Double) {
    
    let animate = CAKeyframeAnimation.init(keyPath: "position")
    animate.isRemovedOnCompletion = false
    animate.path = path.cgPath
    animate.isRemovedOnCompletion = false
    animate.fillMode = .forwards
    animate.calculationMode = .cubic
    animate.repeatCount = HUGE
    animate.duration = time
    animate.autoreverses = false
    animate.timingFunctions = [CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)]
    layer?.add(animate, forKey: "animation")
  }
  
  func colorAnimation(_ layer: CALayer?, fromColor: UIColor, toColor: UIColor, time: Double) {
    
    let colorAnimate = CABasicAnimation(keyPath: "backgroundColor")
    colorAnimate.isRemovedOnCompletion = false
    colorAnimate.toValue = toColor.cgColor
    colorAnimate.fromValue = fromColor.cgColor
    colorAnimate.duration = time
    colorAnimate.autoreverses = false
    colorAnimate.fillMode = .forwards
    colorAnimate.isRemovedOnCompletion = false
    colorAnimate.repeatCount = HUGE
    layer?.add(colorAnimate, forKey: "backgroundColor")
  }
}
