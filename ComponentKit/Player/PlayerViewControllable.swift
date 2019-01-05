//
//  PlayerViewControllable.swift
//  TecentCloud
//
//  Created by William Lee on 2018/12/12.
//  Copyright © 2018 William Lee. All rights reserved.
//

import Foundation

/// 监听PlayerView的g播放操作事件
public protocol PlayerViewControllable {
  
  /// 当PlayerView创建的时候，将会调用该函数，用于保存playerView对象
  func update(playerView: PlayerView)
  
  /// 当PlayerView更新数据的时候，将调用该函数，用于遵循本协议的视图进行缩略图更新
  ///
  /// - Parameter thumb: UIImage或者String类型的图片地址
  func update(thumb: Any?)
  
  /// PlayerView播放开始的时候调用
  func playerViewDidPlay(_ playerView: PlayerView)
  
  /// PlayerView播放暂停的时候调用
  func playerViewDidPause(_ playerView: PlayerView)
  
  /// PlayerView继续播放的时候调用
  func playerViewDidResume(_ playerView: PlayerView)
  
  /// PlayerView播放停止的时候调用
  func playerViewDidStop(_ playerView: PlayerView)
  
  /// PlayerView播放完成的时候调用
  func playerViewDidComplete(_ playerView: PlayerView)
  
  /// PlayerView全屏模式发生变化
  func playerView(_ playerView: PlayerView, didChangedScreenMode mode: PlayerView.ScreenMode)
  
  /// PlayerView播放进度
  func playerView(_ playerView: PlayerView, updateProgressWithCurrentTime currentTime: Double, totalTime: Double)
  
  /// PlayerView缓冲进度
  func playerView(_ playerView: PlayerView, updateProgressWithBufferingTime bufferingTime: Double, totalTime: Double)
}
