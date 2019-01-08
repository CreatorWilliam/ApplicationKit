//
//  CountDownTimer.swift
//  ComponentKit
//
//  Created by William Lee on 09/02/2018.
//  Copyright © 2018 William Lee. All rights reserved.
//

import Foundation

public class CountDownTimer {
  
  private var timer: Timer?
  
  private var deadLineDate: Date = Date()
  private var dateComponents:DateComponents = DateComponents()
  
  // 时间每过1S就进行一次回调
  private var updateHandle: UpdateHandle?
  /// 时间结束后，进行回调
  private var endHandle: TimeEndHandle?
  
  public init() { }
  
  deinit {
    
    self.stop()    
  }
  
}

// MARK: - Public
public extension CountDownTimer {
  
  public typealias UpdateHandle = (DateComponents) -> Void
  public typealias TimeEndHandle = () -> Void
  
  /// 开始倒计时
  ///
  /// - Parameters:
  ///   - date: 结束时间
  ///   - update: 每过一秒进行一次回调
  ///   - timeEnd: 时间结束进行回调
  func start(withDeadline date: Date, update: UpdateHandle? = nil, timeEnd: TimeEndHandle? = nil) {
    
    // 停止可能运行中的Timer
    self.timer?.invalidate()

    self.deadLineDate = date
    self.updateHandle = update
    self.endHandle = timeEnd
    
    
    //正常启动
    self.timer = Timer(timeInterval: 1, target: self, selector: #selector(update(_:)), userInfo: nil, repeats: true)
    guard let temp = self.timer else { return }
    RunLoop.main.add(temp, forMode: RunLoop.Mode.common)
    self.timer?.fire()
    
  }
  
  func cancel() {
    
    self.timer?.invalidate()
    
    self.timer = nil
    self.updateHandle = nil
    self.endHandle = nil
  }
  
  /// 停止倒计时,同时会清空回调
  func stop() {
    
    self.endHandle?()
    self.cancel()
  }
  
}

// MARK: - Utility
private extension CountDownTimer {
  
  
  /// 更新倒计时
  ///
  /// - Parameter timer: 定时器
  @objc func update(_ timer: Timer) {
    
    //var isEnd: Bool = false
    
    defer {
      
      //更新显示
      self.updateHandle?(self.dateComponents)
    }
    
    //计算倒计时
    let fromDate: Date = Date()
    let toDate: Date = self.deadLineDate
    self.dateComponents = Calendar.current.dateComponents([.day, .hour, .minute, .second], from: fromDate, to: toDate)
    
    //判断是否到期，如果到了截至日期，则停止倒计时
    if let day = self.dateComponents.day,
      let hour = self.dateComponents.hour,
      let minute = self.dateComponents.minute,
      let second = self.dateComponents.second,
      day <= 0,
      hour <= 0,
      minute <= 0,
      second <= 0 {
      
      self.dateComponents.day = 0
      self.dateComponents.hour = 0
      self.dateComponents.minute = 0
      self.dateComponents.second = 0
      
      self.stop()
    }
  }
  
}
