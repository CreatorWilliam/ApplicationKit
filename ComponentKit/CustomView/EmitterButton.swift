//
//  EmitterButton.swift
//  MagicEnglish
//
//  Created by Hiu on 2018/6/8.
//  Copyright © 2018年 飞进科技. All rights reserved.
//

import UIKit

public class EmitterButton: UIButton {

  private var explosionLayer = CAEmitterLayer()
  
  public override init(frame: CGRect) {
    super.init(frame: frame)
    
    self.setupExplosion()
  }
  
  public required init?(coder aDecoder: NSCoder) {
    
    fatalError("init(coder:) has not been implemented")
  }

  
  //MARK:创建发射层
  func setupExplosion() {
    
    let explosionCell = CAEmitterCell.init()
    explosionCell.name = "explosion"
    //设置粒子颜色alpha能改变的范围
    explosionCell.alphaRange = 0.10
    //粒子alpha的改变速度
    explosionCell.alphaSpeed = -1.0
    //粒子的生命周期
    explosionCell.lifetime = 0.7
    //粒子生命周期的范围
    explosionCell.lifetimeRange = 0.3
    //粒子发射的初始速度
    explosionCell.birthRate = 2500
    //粒子的速度
    explosionCell.velocity = 40.00
    //粒子速度范围
    explosionCell.velocityRange = 10.00
    //粒子的缩放比例
    explosionCell.scale = 0.03
    //缩放比例范围
    explosionCell.scaleRange = 0.02
    //粒子要展现的图片
    explosionCell.contents = UIImage(named: "short_video_like_selected")?.cgImage
    
    self.explosionLayer.name = "explosionLayer"
    //发射源的形状
    self.explosionLayer.emitterShape = CAEmitterLayerEmitterShape.circle
    //发射模式
    self.explosionLayer.emitterMode = CAEmitterLayerEmitterMode.outline
    //发射源大小
    self.explosionLayer.emitterSize = CGSize.init(width: 5, height: 0)
    //发射源包含的粒子
    self.explosionLayer.emitterCells = [explosionCell]
    //渲染模式
    self.explosionLayer.renderMode = CAEmitterLayerRenderMode.oldestFirst
    self.explosionLayer.masksToBounds = false
    self.explosionLayer.birthRate = 0
    //发射位置
    self.explosionLayer.position = CGPoint.init(x: frame.size.width/2, y: frame.size.height/2)
    self.explosionLayer.zPosition = 0
    self.layer.addSublayer(self.explosionLayer)
    
  }
  
}

// MARK: - Public
public extension EmitterButton {
  
  func update(isSelected: Bool, isAnimated: Bool) {
    
    self.isSelected = isSelected
    guard isAnimated == true else { return }
    self.explosionAnimation()
  }
  
}

// MARK: - Action
private extension EmitterButton {
  
}

// MARK: - Utility
private extension EmitterButton {
  
  //发射的动画
  func explosionAnimation() {
    
    let animation = CAKeyframeAnimation(keyPath: "transform.scale")
    if isSelected {
      animation.values = [1.5, 0.8, 1.0, 1.2, 1.0]
      animation.duration = 0.5
      
      //      startAnimation()
    } else {
      
      animation.values = [0.8, 1.0]
      animation.duration = 0.4
    }
    
    animation.calculationMode = CAAnimationCalculationMode.cubic
    self.layer.add(animation, forKey: "transform.scale")
  }
  
  //开始动画
//  func startAnimation() {
//
//    self.self.explosionLayer.beginTime = CACurrentMediaTime()
//    self.self.explosionLayer.birthRate = 1
//    DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
//
//      self.stopAnimation()
//    }
//  }
//  //结束动画
//  func stopAnimation() {
//
//    self.self.explosionLayer.birthRate = 0
//  }
  
}










