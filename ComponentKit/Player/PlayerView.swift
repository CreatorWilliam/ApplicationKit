//
//  PlayerView.swift
//  TecentCloud
//
//  Created by William Lee on 2018/12/12.
//  Copyright © 2018 William Lee. All rights reserved.
//

import ApplicationKit
import AVFoundation
import UIKit

public class PlayerView: UIView {
  
  /// 视频控制视图
  public let controlView: PlayerViewControllable & UIView
  /// 是否自动播放
  public var isAutoPlay: Bool = false
  /// 是否循环播放
  public var isRepeat: Bool = false
  /// 是否可以根据设备方向旋转
  public var isRotationEnable: Bool = false
  /// 内容页，承载视频播放，视频控制视图，切换全屏模式，也是操纵该视图
  private let contentView = UIView()
  /// 放置视频播放Layer
  private let playerLayerView = UIView()
  /// 缩略图
  private var thumb: String?
  /// 视频播放数据源
  private var playerItem: AVPlayerItem? {
    
    willSet {
      
      guard playerItem != newValue else { return }
      NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: nil)
      playerItem?.removeObserver(self, forKeyPath: #keyPath(AVPlayerItem.status))
      playerItem?.removeObserver(self, forKeyPath: #keyPath(AVPlayerItem.loadedTimeRanges))
      playerItem?.removeObserver(self, forKeyPath: #keyPath(AVPlayerItem.playbackBufferEmpty))
      playerItem?.removeObserver(self, forKeyPath: #keyPath(AVPlayerItem.playbackLikelyToKeepUp))
    }
    
    didSet {
      
      guard playerItem != oldValue else { return }
      NotificationCenter.default.addObserver(self, selector: #selector(playerDidPlayToEnd), name: .AVPlayerItemDidPlayToEndTime, object: nil)
      playerItem?.addObserver(self, forKeyPath: #keyPath(AVPlayerItem.status), options: .new, context: nil)
      playerItem?.addObserver(self, forKeyPath: #keyPath(AVPlayerItem.loadedTimeRanges), options: .new, context: nil)
      // 缓冲区空了，需要等待数据
      playerItem?.addObserver(self, forKeyPath: #keyPath(AVPlayerItem.playbackBufferEmpty), options: .new, context: nil)
      // 缓冲区有足够数据可以播放了
      playerItem?.addObserver(self, forKeyPath: #keyPath(AVPlayerItem.playbackLikelyToKeepUp), options: .new, context: nil)
    }
  }
  private let player = AVPlayer()
  private let playerLayer = AVPlayerLayer()
  
  /// 表示当前视频画面模式，默认自适应
  public var mode: RenderMode = .fit {
    
    didSet {
      switch mode {
      case .fit: playerLayer.videoGravity = .resizeAspect
      case .fill: playerLayer.videoGravity = .resizeAspectFill
      }
    }
  }
  /// 播放状态，表示当前播放情况
  public private(set) var playState: PlayState = .prepared
  /// 加载状态，表示当前视频加载情况，对于本地视频，直接为完成
  public private(set) var loadState: LoadState = .prepared
  /// 用于延迟旋转，避免因设备多次变换导致界面经常变换
  private var isRotationComplete: Bool = true
  // TODO: 是否锁定全屏
  private var isLockScreen: Bool = false
  
  private var timeObserver: Any?
  
  /// 播放器视图，用于播放各类视频
  ///
  /// - Parameters:
  ///   - frame: 视图frame，默认为zero，支持约束布局
  ///   - controlView: 播放控制视图，默认为PlayerDefaultControlView，可提供遵循PlayerControlViewCompatible协议的视图来自定义
  public init(frame: CGRect = .zero,
              controlView: (PlayerViewControllable & UIView) = PlayerViewDefaultControlView()) {
    
    self.controlView = controlView
    
    super.init(frame: frame)
    
    timeObserver = player.addPeriodicTimeObserver(forInterval: CMTime(value: 1, timescale: 1), queue: DispatchQueue.main, using: { [unowned self] (time) in
      
      guard self.playerItem?.duration.seconds.isNaN == false else { return }
      controlView.playerView(self, updateProgressWithCurrentTime: self.playerItem?.currentTime().seconds ?? 0, totalTime: self.playerItem?.duration.seconds ?? 1)
    })
    controlView.update(playerView: self)
    controlView.playerView(self, didChangedScreenMode: .shrink)
    
    setupUI()
    
    addNotification()
    
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  public override func layoutSubviews() {
    super.layoutSubviews()
    
    defer {
      
      playerLayer.frame = contentView.bounds
    }
    // 仅当作为子视图的时候，才设置大小
    if contentView.superview != self { return }
    contentView.frame = bounds
  }
  
  deinit {
    
    stop()
    
    if let timeObserver = timeObserver {
      
      player.removeTimeObserver(timeObserver)
    }
    
    removeNotification()
    
    // 可能添加到UIWindow上并持有，因此需要移除销毁
    contentView.removeFromSuperview()
  }
  
}

// MARK: - Public
public extension PlayerView {
  
  /// 视频渲染模式
  enum RenderMode {
    
    /// 填充，多用于直播，无黑边
    case fill
    /// 适应，多用于点播，有黑边
    case fit
  }
  
  /// 播放状态
  enum PlayState: Equatable {
    
    /// 播放准备
    case prepared
    /// 播放中
    case playing
    /// 播放终止
    case stopped
    /// 播放暂停
    case paused
    /// 播放失败
    case failed
  }
  
  /// 视频加载状态
  enum LoadState: Equatable {
    /// 加载准备
    case prepared
    /// 加载失败
    case failed(String)
    /// 加载中
    case buffering
    /// 加载完成
    case complete
  }
  
  enum ScreenMode {
    /// 全屏
    case full
    /// 缩放
    case shrink
    /// 悬浮
    case float
  }
  
  func update(withURL url: String?, andThumb thumb: String?) {
    
    guard let urlString = url?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return }
    guard let url = URL(string: urlString) else { return }
    
    //playerItem = AVPlayerItem(url: PlayerCacher.shared.url(withRemote: url))
    playerItem = AVPlayerItem(url: url)
    player.pause()
    player.replaceCurrentItem(with: playerItem)
    
    self.thumb = thumb
    controlView.update(thumb: thumb)
    
    playState = .prepared
    controlView.playerView(self, updateProgressWithCurrentTime: 0, totalTime: 0)
  }
  
  func play() {
    
    guard playerItem != nil else { return }
    
    player.play()
    playState = .playing
    controlView.playerViewDidPlay(self)
  }
  
  func pause() {
    
    player.pause()
    playState = .paused
    controlView.playerViewDidPause(self)
  }
  
  func stop() {
    
    /// 设置nil触发该属性的didSet方法，释放观察者
    playerItem = nil
    
    player.pause()
    player.seek(to: CMTime(value: 0, timescale: 1))
    playState = .stopped
    controlView.playerViewDidStop(self)
  }
  
  func seek(with progress: Float) {
    
    guard let item = playerItem else { return }
    let progress: Double = progress > 1 ? 1 : Double(progress)
    let time = item.duration.seconds * progress
    player.seek(to: CMTime(seconds: time, preferredTimescale: 1), completionHandler: { (_) in
      
    })
  }
  
  func joinFullScreen() {
    
    contentView.backgroundColor = .black
    controlView.playerView(self, didChangedScreenMode: .full)
    updateRotation(with: .landscapeLeft)
  }
  
  func quitFullScreen() {
    
    controlView.playerView(self, didChangedScreenMode: .shrink)
    updateRotation(with: .portrait)
  }
  
}

// MARK: - Setup
private extension PlayerView {
  
  func setupUI() {
    
    playerLayer.player = player
    addSubview(contentView)
    
    playerLayerView.layer.addSublayer(playerLayer)
    contentView.addSubview(playerLayerView)
    playerLayerView.layout.add { (make) in
      make.top().bottom().leading().trailing().equal(contentView)
    }
    
    let controlView: UIView = self.controlView
    contentView.addSubview(controlView)
    controlView.layout.add { (make) in
      make.top().bottom().leading().trailing().equal(contentView)
    }
  }
  
}

// MARK: - PlayerObserver
extension PlayerView {
  
  @objc func playerDidPlayToEnd(_ notification: Notification) {
    
    // 避免黑屏
    player.pause()
    player.seek(to: CMTime(value: 0, timescale: 1))
    playState = .stopped
    controlView.playerViewDidComplete(self)
    
    guard isRepeat == true else { return }
    
    play()
  }
  
  public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
    
    guard let keyPath = keyPath else { return }
    guard let item = object as? AVPlayerItem else { return }
    guard item == playerItem else { return }
    switch keyPath {
      
    case #keyPath(AVPlayerItem.status):
      
      playerStatusDidChanged(item)
      
    case #keyPath(AVPlayerItem.loadedTimeRanges):
      
      playerBufferDidChanged(item)
      
    case #keyPath(AVPlayerItem.playbackBufferEmpty):
      
      // TODO: 缓冲不足，显示Loading
      DebugLog("AVPlayerItem's playbackBufferEmpty is changed: \(item.isPlaybackBufferEmpty)")
      
    case #keyPath(AVPlayerItem.playbackLikelyToKeepUp):
      
      // TODO: 缓冲足够，隐藏Loading
      DebugLog("AVPlayerItem's playbackLikelyToKeepUp is changed: \(item.isPlaybackLikelyToKeepUp)")
      
    default:
      
      break
    }
  }
}

// MARK: - Player StateHandler
private extension PlayerView {
  
  func playerStatusDidChanged(_ item: AVPlayerItem) {
    
    DebugLog("AVPlayerItem's status is changed: \(item.status)")
    
    if item.status == .failed {
      
      loadState = .failed(item.error?.localizedDescription ?? "- -")
      return
    }
    
    guard item.status == .readyToPlay else { return }
    
    //自动播放：设置了自动播放，且播放状态处于已准备
    guard isAutoPlay == true && playState == .prepared else { return }
    
    play()
  }
  
  func playerBufferDidChanged(_ item: AVPlayerItem) {
    
    //获取缓冲进度,第一个即最新的一个缓冲区域
    guard let timeRange = item.loadedTimeRanges.first?.timeRangeValue else { return }
    let startSeconds = timeRange.start.seconds //开始的时间
    let durationSecound = timeRange.duration.seconds//表示已经缓冲的时间
    let bufferDuration = startSeconds + durationSecound // 计算缓冲总时间
    DebugLog("AVPlayerItem's loadedTimeRanges is changed, current: \(bufferDuration)s - total: \(item.duration.seconds)s")
    guard item.duration.seconds.isNaN == false else { return }
    controlView.playerView(self, updateProgressWithBufferingTime: bufferDuration, totalTime: item.duration.seconds)
  }
  
}

// MARK: - Notification
private extension PlayerView {
  
  func addNotification() {
    
    // App即将进入前台
    NotificationCenter.default.addObserver(self,
                                           selector: #selector(recieveApplicationWillEnterForeground),
                                           name: UIApplication.willEnterForegroundNotification,
                                           object: nil)
    // App已经进入前台
    NotificationCenter.default.addObserver(self,
                                           selector: #selector(recieveApplicationDidBecomeActive),
                                           name: UIApplication.didBecomeActiveNotification,
                                           object: nil)
    // App即将进入后台
    NotificationCenter.default.addObserver(self,
                                           selector: #selector(recieveApplicationWillResignActive),
                                           name: UIApplication.willResignActiveNotification,
                                           object: nil)
    // App已经进入后台
    NotificationCenter.default.addObserver(self,
                                           selector: #selector(recieveApplicationDidEnterBackground),
                                           name: UIApplication.didEnterBackgroundNotification,
                                           object: nil)
    // 监听耳机插入和拔掉通知
    NotificationCenter.default.addObserver(self,
                                           selector: #selector(recieveRouteChange),
                                           name: AVAudioSession.routeChangeNotification,
                                           object: nil)
    // 监测设备方向
    UIDevice.current.beginGeneratingDeviceOrientationNotifications()
    NotificationCenter.default.addObserver(self,
                                           selector: #selector(recieveOrientationDidChange),
                                           name: UIDevice.orientationDidChangeNotification,
                                           object: nil)
  }
  
  func removeNotification() {
    
    NotificationCenter.default.removeObserver(self)
  }
  
  @objc func recieveApplicationWillEnterForeground(_ notification: Notification) {
    
  }
  
  @objc func recieveApplicationDidBecomeActive(_ notification: Notification) {
    
    if isAutoPlay == false { return }
    if playState == .stopped { return }
    play()
  }
  
  @objc func recieveApplicationWillResignActive(_ notification: Notification) {
    
    if playState != .playing { return }
    pause()
  }
  
  @objc func recieveApplicationDidEnterBackground(_ notification: Notification) {
    
  }
  
  @objc func recieveRouteChange(_ notification: Notification) {
    
    if playState != .playing { return }
    pause()
  }
  
  @objc func recieveOrientationDidChange(_ notification: Notification) {
    
    guard isRotationEnable == true else { return }
    let orientation = UIDevice.current.orientation
    switch orientation {
    case .portrait: commitRotationUpdateTask(with: .portrait)
    case .portraitUpsideDown: commitRotationUpdateTask(with: .portraitUpsideDown)
    case .landscapeLeft: commitRotationUpdateTask(with: .landscapeLeft)
    case .landscapeRight: commitRotationUpdateTask(with: .landscapeRight)
    default: break
    }
  }
  
}

// MARK: - Layout
private extension PlayerView {
  
  func commitRotationUpdateTask(with orientation: UIInterfaceOrientation) {
    
    // 锁定屏幕将不会更新界面布局
    if isLockScreen == true { return }
    
    // 提交的界面更新未完成，将不再重复提交，将根据最终执行更新任务时的方向为依据，保证更新时界面方向正确性
    guard isRotationComplete == true else { return }
    
    isRotationComplete = false
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
      
      self.isRotationComplete = true
      
      // 获取当前设备的方向所对应的交互方向
      let orientation: UIInterfaceOrientation
      switch UIDevice.current.orientation {
      case .faceUp, .faceDown, .unknown: return
      case .landscapeLeft: orientation = .landscapeLeft
      case .landscapeRight: orientation = .landscapeRight
      case .portrait: orientation = .portrait
      case .portraitUpsideDown: orientation = .portraitUpsideDown
      default: return
      }
      self.updateRotation(with: orientation)
    })
  }
  
  /// 根据给定的方向适配播放器界面,在横屏状态下，会进入全屏模式
  ///
  /// - Parameter orientation: 要做适配的方向
  func updateRotation(with orientation: UIInterfaceOrientation) {
    
    // 获取到当前状态栏的方向
    //let statusBarOrientation = UIApplication.shared.statusBarOrientation
    
    let transform: CGAffineTransform
    let size: CGSize
    
    switch orientation {
    case .landscapeLeft:
      
      transform = CGAffineTransform.identity.rotated(by: (CGFloat.pi / 2.0))
      size = CGSize(width: UIScreen.main.bounds.height, height: UIScreen.main.bounds.width)
      UIApplication.shared.keyWindow?.addSubview(contentView)
      
    case .landscapeRight:
      
      transform = CGAffineTransform.identity.rotated(by: -(CGFloat.pi / 2.0))
      size = CGSize(width: UIScreen.main.bounds.height, height: UIScreen.main.bounds.width)
      UIApplication.shared.keyWindow?.addSubview(contentView)
      
    default:
      
      transform = CGAffineTransform.identity
      size = frame.size
      addSubview(contentView)
    }
    
    // 使用视图角度旋转的方式实现画面旋转
    UIView.beginAnimations(nil, context: nil)
    
    contentView.frame = CGRect(origin: .zero, size: size)
    contentView.transform = transform
    contentView.frame.origin = .zero
    playerLayer.frame = contentView.bounds
    contentView.layoutIfNeeded()
    
    UIView.commitAnimations()
  }
  
}
