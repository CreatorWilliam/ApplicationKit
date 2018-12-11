//
//  LoadingView.swift
//  ComponentKit
//
//  Created by William Lee on 21/12/17.
//  Copyright © 2018 William Lee. All rights reserved.
//

import UIKit

class LoadingView: UIView {
  
  private var roundLayers: [CALayer] = []
  private var containerLayer: CALayer = CALayer()
  
  private static var foreground: UIColor = UIColor.white
  private static var background: UIColor = UIColor.black.withAlphaComponent(0.6)
  
  public override init(frame: CGRect) {
    super.init(frame: frame)
    
    self.setupUI()
  }
  
  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    let radius: CGFloat = 12;
    let center: CGPoint = CGPoint(x: self.bounds.width / 2, y: self.bounds.height / 2)
    self.containerLayer.frame = CGRect(x: center.x - radius * 4, y: center.y - radius * 4, width: radius * 8, height: radius * 8)
  }
  
}

// MARK: - Appearance
extension LoadingView {
  
  class func `default`(foreground: UIColor = UIColor.white, background: UIColor = UIColor.black.withAlphaComponent(0.6)) {
    
    self.foreground = foreground
    self.background = background
  }
  
}

// MARK: - Action
extension LoadingView {
  
  func start() {
    
    let values = (0  ..< 8).map { CATransform3DMakeScale(CGFloat(8 - $0) / 8, CGFloat(8 - $0) / 8, 1.0)}
    for (index, roundLayer) in self.roundLayers.enumerated() {
      
      let transformAnimation = CAKeyframeAnimation(keyPath: "transform")
      transformAnimation.duration = 1.5
      transformAnimation.repeatDuration = 10000
      let leftValues = values[0 ..< index]
      let rightValues = values[index ..< self.roundLayers.count]
      var tempValues: [CATransform3D] = []
      tempValues.append(contentsOf: rightValues)
      tempValues.append(contentsOf: leftValues)
      transformAnimation.values = tempValues
      roundLayer.add(transformAnimation, forKey: nil)
    }
    
  }
  
  func stop() {
    
    self.roundLayers.forEach { $0.removeAllAnimations() }
  }
  
}

// MARK: - CAAnimationDelegate
extension LoadingView: CAAnimationDelegate {
  
  public func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
    
    self.stop()
    
  }
}

// MARK: - Setup
private extension LoadingView {
  
  func setupUI() -> Void {
    
    //view
    self.backgroundColor = .clear
    
    // 圆点直径
    let diameter: CGFloat = 12
    
    // 容器圆角
    self.containerLayer.cornerRadius = 10
    // 容器背景色
    self.containerLayer.backgroundColor = LoadingView.background.cgColor
    // 容器初始坐标
    self.containerLayer.frame = CGRect(x: self.bounds.width / 2 - diameter * 4, y: self.bounds.height / 2 - diameter * 4, width: diameter * 8, height: diameter * 8)
    self.layer.addSublayer(self.containerLayer)
    
    // 容器中心点
    let center: CGPoint = CGPoint(x: self.containerLayer.bounds.width / 2, y: self.containerLayer.bounds.height / 2)
    
    for index in 0 ..< 8 {
      
      // 圆点
      let roundLayer = CALayer()
      self.roundLayers.append(roundLayer)
      
      // 圆点围绕中心点的角度
      let angle: CGFloat = CGFloat(index) * (CGFloat.pi / 4)
      // 圆点的中心 X
      let centerX = cos(angle) * diameter * 2 + center.x
      // 圆点的中心 Y
      let centerY = sin(angle) * diameter * 2 + center.y
      // 圆点半径
      roundLayer.cornerRadius = diameter / 2
      // 圆点背景色
      roundLayer.backgroundColor = LoadingView.foreground.cgColor
      // 圆点坐标
      roundLayer.frame = CGRect(x: centerX - diameter / 2, y: centerY - diameter / 2, width: diameter, height: diameter)
      self.containerLayer.addSublayer(roundLayer)
      
    }
    
  }
  
  func setupAnimation(path: UIBezierPath, and opacityValue: CGPoint) -> (CAKeyframeAnimation, CABasicAnimation) {
    
    let animationDuration: CFTimeInterval = 1.5
    let repeatDuration: CFTimeInterval = 25
    
    let pathAnimation: CAKeyframeAnimation = CAKeyframeAnimation(keyPath: "position")
    pathAnimation.delegate = self
    pathAnimation.path = path.cgPath
    pathAnimation.repeatDuration = repeatDuration
    pathAnimation.duration = animationDuration
    //pathAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
    
    let opacityAnimation: CABasicAnimation = CABasicAnimation(keyPath: "opacity")
    opacityAnimation.delegate = self
    opacityAnimation.repeatDuration = repeatDuration
    opacityAnimation.duration = animationDuration
    opacityAnimation.fromValue = opacityValue.x
    opacityAnimation.toValue = opacityValue.y
    
    return (pathAnimation, opacityAnimation)
  }
  
}
