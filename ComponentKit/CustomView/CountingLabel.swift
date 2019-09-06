//
//  CountingLabel.swift
//  ComponentKit
//
//  Created by William Lee on 2019/1/8.
//  Copyright © 2019 William Lee. All rights reserved.
//

import ApplicationKit
import UIKit

public protocol CountingLabelDelegate: class {
  
  func countingLabelDidEndCountingAnimation(_ label: CountingLabel)
  
}

/// 动画显示数字文字
public class CountingLabel: UILabel {
  
  public weak var delegate: CountingLabelDelegate?
  
  /// 数字格式化样式如："%.0f"
  public var format: String = "%.0f"
  /// 动画样式
  public var animation: Animation = .easeIn
  /// 动画持续时间
  public var animationDuration: TimeInterval = 0
  
  private var startValue: Float = 0
  private var endValue: Float = 0
  private var excuteTime: TimeInterval = 0
  private var lastUpdateTime: TimeInterval = 0
  private var totalTime: TimeInterval = 0
  private var easingRate: Float = 3.0
  
  private var timer: CADisplayLink?
  
}

// MARK: - Animation
public extension CountingLabel {
  
  enum Animation {
    
    case easeInOut
    case easeIn
    case easeOut
    case linear
    case easeInBounce
    case easeOutBounce
    
    func update(_ value: Float) -> Float {
      
      var value = value
      
      let rate: Float = 3.0
      
      switch self {
      case .easeIn:
        
        return powf(value, rate)
        
      case .easeInOut:
        
        value *= 2
        return value < 1 ? 0.5 * powf (value, rate) : 0.5 * (2.0 - powf(2.0 - value, rate))
        
      case .easeOut:
        
        return 1.0 - powf((1.0 - value), rate)
        
      case .linear:
        
        return value
        
      case .easeInBounce:
        
        if (value < 4.0 / 11.0) {
          
          return 1.0 - (powf(11.0 / 4.0, 2) * powf(value, 2)) - value
        }
        
        if (value < 8.0 / 11.0) {
          
          return 1.0 - (3.0 / 4.0 + powf(11.0 / 4.0, 2) * powf(value - 6.0 / 11.0, 2)) - value
        }
        
        if (value < 10.0 / 11.0) {
          
          return 1.0 - (15.0 / 16.0 + powf(11.0 / 4.0, 2) * powf(value - 9.0 / 11.0, 2)) - value
        }
        
        return 1.0 - (63.0 / 64.0 + powf(11.0 / 4.0, 2) * powf(value - 21.0 / 22.0, 2)) - value
        
      case .easeOutBounce:
        
        if (value < 4.0 / 11.0) {
          
          return powf(11.0 / 4.0, 2) * powf(value, 2)
        }
        
        if (value < 8.0 / 11.0) {
          
          return 3.0 / 4.0 + powf(11.0 / 4.0, 2) * powf(value - 6.0 / 11.0, 2)
        }
        
        if (value < 10.0 / 11.0) {
          return 15.0 / 16.0 + powf(11.0 / 4.0, 2) * powf(value - 9.0 / 11.0, 2)
        }
        
        return 63.0 / 64.0 + powf(11.0 / 4.0, 2) * powf(value - 21.0 / 22.0, 2)
        
      }
    }
    
  }
  
}

// MARK: - Public
public extension CountingLabel {
  
  func countFromCurrentValue(to endValue: Float) {
    
    self.count(from: self.currentValue, to: endValue)
  }
  
  func count(from startValue: Float, to endValue: Float, with duration: TimeInterval = 2.0) {
  
    self.startValue = startValue
    self.endValue = endValue
    
    self.timer?.invalidate()
    self.timer = nil;
    
    guard (duration > 0.0) else {
      
      self.setText(endValue)
      self.delegate?.countingLabelDidEndCountingAnimation(self)
      return
    }
    
    self.excuteTime = 0
    self.totalTime = duration
    self.lastUpdateTime = Date.timeIntervalSinceReferenceDate
    
    self.timer = CADisplayLink(target: self, selector: #selector(updateValue))
    if #available(iOS 10, *) {

      self.timer?.preferredFramesPerSecond = 30

    } else {
    
      self.timer?.frameInterval = 2
    }
    self.timer?.add(to: .main, forMode: .default)
    self.timer?.add(to: .main, forMode: .tracking)
  }
  
}

// MARK: - Action
private extension CountingLabel {
  
  @objc func updateValue(_ timer: CADisplayLink) {
    
    // update progress
    let currentTime = Date.timeIntervalSinceReferenceDate
    self.excuteTime += currentTime - self.lastUpdateTime
    self.lastUpdateTime = currentTime
    
    self.setText(self.currentValue)
    
    guard self.excuteTime >= self.totalTime else { return }
    
    self.timer?.invalidate()
    self.timer = nil
    
    self.delegate?.countingLabelDidEndCountingAnimation(self)
  }
  
}

// MARK: - Utility
private extension CountingLabel {
  
  var currentValue: Float {
    
    if self.excuteTime >= self.totalTime { return self.endValue }
    
    let percent = self.excuteTime / self.totalTime
    
    let updateRate = self.animation.update(Float(percent))
    
    return self.startValue + (updateRate * (self.endValue - self.startValue));
  }
  
  func setText(_ value: Float) {
    
    self.text = String(format: self.format, value)
  }
  
}
