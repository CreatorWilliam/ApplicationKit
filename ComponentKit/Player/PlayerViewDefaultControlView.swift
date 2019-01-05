//
//  PlayerViewDefaultControlView.swift
//  TecentCloud
//
//  Created by William Lee on 2018/12/12.
//  Copyright © 2018 William Lee. All rights reserved.
//

import ApplicationKit

public class PlayerViewDefaultControlView: UIView {
  
  /// 背景部分控件的容器
  public let backgroundContainer = UIView()
  /// 顶部部分控件的容器
  public let topContainer = UIView()
  /// 中间部分控件的容器
  public let centerContainer = UIView()
  /// 底部部分控件的容器
  public let bottomContainer = UIView()

  /// 保存播放器，用于界面控制进行通知
  private weak var playerView: PlayerView?
  
  /// Top - 点击返回按钮，将退出全屏显示
  private let backButton = UIButton(type: .custom)
  /// Top - 视频标题显示
  private let titleLabel = UILabel()
  
  /// Center - 亮度调节滑块（左）
  private let brightnessSlider = UISlider()
  /// Center - 音量调节滑块（右）
  private let volumeSlider = UISlider()
  /// Center - 中央显示的播放状态操作按钮
  private let centerPlayStateButton = UIButton(type: .custom)
  /// 锁定按钮，锁定后禁用亮度、音量调节
  //private let lockButton = UIButton(type: .custom)
  
  /// Bottom - 底部显示的播放状态操作按钮
  private let bottomPlayStateButton = UIButton(type: .custom)
  /// Bottom - 当前播放时间
  private let currentTimeLabel = UILabel()
  /// Bottom - 视频时长
  private let totalTimeLabel = UILabel()
  /// Bottom - 播放进度滑块
  private let progressSlider = UISlider()
  /// Bottom - 缓冲进度条
  private let bufferingProgressView = UIProgressView()
  /// Bottom - 播放界面全屏/收缩切换
  private let screenButton = UIButton(type: .custom)
  
  /// Background - 显示视频缩略图
  private let thumbView = UIImageView()
  
  /// 单击界面，显示控制界面
  private let singleTapGestureRecognizer = UITapGestureRecognizer()
  /// 双击界面，开始/暂停播放
  private let doubleTapGestureRecognizer = UITapGestureRecognizer()
  
  public override init(frame: CGRect) {
    super.init(frame: frame)
    
    self.setupUI()
    self.setupGestureRecognizer()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
}

// MARK: - Public
public extension PlayerViewDefaultControlView {
  
}

// MARK: - PlayerControlViewCompatible
extension PlayerViewDefaultControlView: PlayerViewControllable {
  
  public func update(playerView: PlayerView) {
    
    self.playerView = playerView
    
    self.updatePrepareStyle()
    self.showControls(isAnimate: false, shouldHide: false)
  }
  
  public func update(thumb: Any?) {
    
    if let image = thumb as? UIImage { self.thumbView.image = image }
    else if let urlString = thumb as? String { self.thumbView.setImage(with: urlString) }
    else { return }
    
    self.updatePrepareStyle()
    self.showControls(isAnimate: false, shouldHide: false)
  }
  
  public func playerViewDidPlay(_ playerView: PlayerView) {
    
    self.updatePlayingStyle()
    self.hideThumb()
    self.hideControls()
  }
  
  public func playerViewDidPause(_ playerView: PlayerView) {
    
    self.updatePrepareStyle()
    self.showControls(isAnimate: true, shouldHide: false)
  }
  
  public func playerViewDidResume(_ playerView: PlayerView) {
    
    self.updatePlayingStyle()
    self.showControls(isAnimate: true, shouldHide: true)
  }
  
  public func playerViewDidStop(_ playerView: PlayerView) {
    
    self.updatePrepareStyle()
    self.showThumb()
    self.hideControls()
  }
  
  public func playerViewDidComplete(_ playerView: PlayerView) {
    
    self.updateReplayStyle()
    self.showThumb()
    self.hideControls()
  }
  
  public func playerView(_ playerView: PlayerView, didChangedScreenMode mode: PlayerView.ScreenMode) {
    
    let isFullScreen: Bool
    switch mode {
    case .full: isFullScreen = true
    default: isFullScreen = false
    }
    self.screenButton.isSelected = isFullScreen
    self.topContainer.isHidden = !isFullScreen
  }
  
  public func playerView(_ playerView: PlayerView, updateProgressWithCurrentTime currentTime: Double, totalTime: Double) {
    
    self.currentTimeLabel.text = self.time(with: currentTime)
    self.totalTimeLabel.text = self.time(with: totalTime)
    self.progressSlider.value = Float(currentTime / totalTime)
  }
  
  public func playerView(_ playerView: PlayerView, updateProgressWithBufferingTime bufferingTime: Double, totalTime: Double) {
    
    self.bufferingProgressView.progress = Float(bufferingTime / totalTime)
    self.totalTimeLabel.text = self.time(with: totalTime)
  }
  
}

// MARK: - Setup
private extension PlayerViewDefaultControlView {
  
  func setupUI() {
    
    self.backgroundColor = .clear
    
    self.addSubview(self.backgroundContainer)
    self.backgroundContainer.layout.add { (make) in
      make.top().bottom().leading().trailing().equal(self)
    }
    
    self.topContainer.isHidden = true
    self.addSubview(self.topContainer)
    self.topContainer.layout.add { (make) in
      make.top().leading(25).trailing(-5).equal(self)
    }
    
    self.addSubview(self.bottomContainer)
    self.bottomContainer.layout.add { (make) in
      make.leading(25).trailing(-5).bottom(-5).equal(self)
    }
    
    self.addSubview(self.centerContainer)
    self.centerContainer.layout.add { (make) in
      make.top().equal(self.topContainer).bottom()
      make.bottom().equal(self.bottomContainer).top()
      make.leading(5).trailing(-5).equal(self)
    }
    
    self.setupBackgroundUI()
    self.setupTopUI()
    self.setupCenterUI()
    self.setupBottomUI()
  }
  
  func setupBackgroundUI() {
    
    self.thumbView.contentMode = .scaleAspectFit
    self.backgroundContainer.addSubview(self.thumbView)
    self.thumbView.layout.add { (make) in
      make.top().bottom().leading().trailing().equal(self.backgroundContainer)
    }
  }
  
  func setupTopUI() {
    
    self.backButton.setImage(self.image(with: "back"), for: .normal)
    self.backButton.addTarget(self, action: #selector(clickBack), for: .touchUpInside)
    self.topContainer.addSubview(self.backButton)
    self.backButton.layout.add { (make) in
      make.top().bottom().leading().equal(self.topContainer)
      make.height(44)
    }
  }
  
  func setupCenterUI() {
    
    self.centerPlayStateButton.setImage(self.image(with: "play_big"), for: .normal)
    self.centerPlayStateButton.addTarget(self, action: #selector(clickPlayState), for: .touchUpInside)
    self.centerContainer.addSubview(self.centerPlayStateButton)
    self.centerPlayStateButton.layout.add { (make) in
      make.centerX().centerY().equal(self.centerContainer)
    }
  }
  
  func setupBottomUI() {
    
    self.setupAction(self.bottomPlayStateButton, normal: "play_small", selected: "pause_small")
    self.bottomPlayStateButton.addTarget(self, action: #selector(clickPlayState), for: .touchUpInside)
    self.bottomContainer.addSubview(self.bottomPlayStateButton)
    self.bottomPlayStateButton.layout.add { (make) in
      make.top().bottom().leading().equal(self.bottomContainer)
      make.height(30).width(30)
    }
    
    self.setupAction(self.screenButton, normal: "screen_full", selected: "screen_screen_shrink")
    self.screenButton.addTarget(self, action: #selector(clickScreen), for: .touchUpInside)
    self.bottomContainer.addSubview(self.screenButton)
    self.screenButton.layout.add { (make) in
      make.top().bottom().trailing().equal(self.bottomContainer)
      make.height(30).width(30)
    }
    
    self.setupTime(self.currentTimeLabel)
    self.bottomContainer.addSubview(self.currentTimeLabel)
    self.currentTimeLabel.layout.add { (make) in
      make.leading(5).equal(self.bottomPlayStateButton).trailing()
      make.centerY().equal(self.bottomContainer)
      make.hugging(axis: .horizontal)
    }
    
    self.setupTime(self.totalTimeLabel)
    self.bottomContainer.addSubview(self.totalTimeLabel)
    self.totalTimeLabel.layout.add { (make) in
      make.trailing(-5).equal(self.screenButton).leading()
      make.centerY().equal(self.bottomContainer)
      make.hugging(axis: .horizontal)
    }
    
    self.bottomContainer.addSubview(self.bufferingProgressView)
    self.bufferingProgressView.layout.add { (make) in
      make.leading(5).equal(self.currentTimeLabel).trailing()
      make.trailing(-5).equal(self.totalTimeLabel).leading()
      make.centerY().equal(self.bottomContainer)
    }
    
    self.progressSlider.minimumTrackTintColor = UIColor(0x00f5ac)
    self.progressSlider.maximumTrackTintColor = .clear
    self.progressSlider.addTarget(self, action: #selector(slidProgress), for: .valueChanged)
    self.bottomContainer.addSubview(self.progressSlider)
    self.progressSlider.layout.add { (make) in
      make.leading().trailing().centerY().equal(self.bufferingProgressView)
    }
  }
  
  func setupGestureRecognizer() {
    
    self.singleTapGestureRecognizer.addTarget(self, action: #selector(singleTap))
    self.singleTapGestureRecognizer.numberOfTapsRequired = 1
    self.singleTapGestureRecognizer.numberOfTouchesRequired = 1
    self.centerContainer.addGestureRecognizer(self.singleTapGestureRecognizer)
    
    self.doubleTapGestureRecognizer.addTarget(self, action: #selector(doubleTap))
    self.doubleTapGestureRecognizer.numberOfTapsRequired = 2
    self.doubleTapGestureRecognizer.numberOfTouchesRequired = 1
    self.centerContainer.addGestureRecognizer(self.doubleTapGestureRecognizer)
  }
  
  func setupAction(_ button: UIButton, normal normalImage: String, selected selectedImage: String) {
    
    button.setImage(self.image(with: normalImage), for: .normal)
    button.setImage(self.image(with: selectedImage), for: .selected)
  }
  
  func setupTime(_ label: UILabel) {
    
    label.text = "00:00"
    label.font = .systemFont(ofSize: 12)
    label.textColor = .white
    label.textAlignment = .center
  }
  
  func image(with name: String) -> UIImage? {
    
    let frameworkBundle = Bundle(for: PlayerViewDefaultControlView.self)
    guard let bundlePath = frameworkBundle.path(forResource: "Player", ofType: "bundle") else { return nil }
    guard let imageBundle = Bundle(path: bundlePath) else { return nil }
    guard let imagePath = imageBundle.path(forResource: name, ofType: "png") else { return nil }
    return UIImage(contentsOfFile: imagePath)
  }
  
  func time(with time: Double) -> String {
    
    let time = Int(time)
    
    let second = time % 60
    var minute = time / 60
    let hour = minute / 60
    
    guard hour > 0 else {
      return String(format: "%02d:%02d", minute, second)
    }

    minute = minute % 60
    
    return String(format: "%02d:%02d:%02d", hour, minute, second)
  }
}

// MARK: - Action
private extension PlayerViewDefaultControlView {
  
  @objc func clickPlayState(_ sender: UIButton) {
    
    if sender.isSelected == true {
      
      self.playerView?.pause()
      return
    }
    
    self.playerView?.play()
  }
  
  @objc func slidProgress(_ sender: UISlider) {
    
    self.showControls(isAnimate: false, shouldHide: false)
    self.playerView?.pause()
    self.playerView?.seek(with: sender.value)
  }
  
  @objc func clickScreen(_ sender: UIButton) {
    
    if sender.isSelected == true {
      
      self.playerView?.quitFullScreen()
      return
    }
    self.playerView?.joinFullScreen()
  }
  
  @objc func clickBack(_ sender: UIButton) {
    
    self.playerView?.quitFullScreen()
  }
  
  @objc func singleTap(_ sender: UITapGestureRecognizer) {
   
    self.showControls(isAnimate: true, shouldHide: true)
  }
  
  @objc func doubleTap(_ sender: UITapGestureRecognizer) {
    
    self.clickPlayState(self.bottomPlayStateButton)
  }
}

// MARK: - Utility
private extension PlayerViewDefaultControlView {
  
  func showThumb() {
    
    UIView.animate(withDuration: 0.1, animations: {
      
      self.thumbView.alpha = 1
      
    })
  }
  
  func hideThumb() {
    
    UIView.animate(withDuration: 0.25, animations: {
      
      self.thumbView.alpha = 0
      
    })
  }
  
  func showControls(isAnimate: Bool, shouldHide isHidden: Bool) {
    
    
    if isAnimate == false {
      
      self.bottomContainer.alpha = 1
      return
    }
    
    UIView.animate(withDuration: 0.25, animations: {
      
      self.bottomContainer.alpha = 1
      
    }, completion: { (_) in
      
      guard isHidden == true else { return }
      DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: {
        
        self.hideControls()
      })
    })
    
  }
  
  func hideControls(isAnimate: Bool = true) {
    
    if isAnimate == false {
      
      self.bottomContainer.alpha = 0
      return
    }
    
    UIView.animate(withDuration: 0.1, animations: {
      
      self.bottomContainer.alpha = 0
      
    })
  }
  
  func updatePlayingStyle() {
    
    /// 隐藏中间的播放状态按钮
    self.centerPlayStateButton.isHidden = true
    
    /// 暂停样式
    self.bottomPlayStateButton.isSelected = true
  }
  
  func updatePrepareStyle() {
    
    /// 播放样式
    self.centerPlayStateButton.isHidden = false
    self.centerPlayStateButton.setImage(self.image(with: "play_big"), for: .normal)
    
    /// 播放样式
    self.bottomPlayStateButton.isSelected = false
  }
  
  func updateReplayStyle() {
    
    self.centerPlayStateButton.isHidden = false
    self.centerPlayStateButton.setImage(self.image(with: "repeat_big"), for: .normal)
    
    /// 播放样式
    self.bottomPlayStateButton.isSelected = false
  }
  
}
