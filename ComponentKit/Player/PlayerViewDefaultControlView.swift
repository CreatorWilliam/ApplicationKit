//
//  PlayerViewDefaultControlView.swift
//  TecentCloud
//
//  Created by William Lee on 2018/12/12.
//  Copyright © 2018 William Lee. All rights reserved.
//

import ApplicationKit
import UIKit

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
    
    setupUI()
    setupGestureRecognizer()
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
    
    updatePrepareStyle()
    showControls(isAnimate: false, shouldHide: false)
  }
  
  public func update(thumb: Any?) {
    
    if let image = thumb as? UIImage { thumbView.image = image }
    else if let urlString = thumb as? String { thumbView.setImage(with: urlString) }
    else { return }
    
    updatePrepareStyle()
    showControls(isAnimate: false, shouldHide: false)
  }
  
  public func playerViewDidPlay(_ playerView: PlayerView) {
    
    updatePlayingStyle()
    hideThumb()
    hideControls()
  }
  
  public func playerViewDidPause(_ playerView: PlayerView) {
    
    updatePrepareStyle()
    showControls(isAnimate: true, shouldHide: false)
  }
  
  public func playerViewDidResume(_ playerView: PlayerView) {
    
    updatePlayingStyle()
    showControls(isAnimate: true, shouldHide: true)
  }
  
  public func playerViewDidStop(_ playerView: PlayerView) {
    
    updatePrepareStyle()
    showThumb()
    hideControls()
  }
  
  public func playerViewDidComplete(_ playerView: PlayerView) {
    
    updateReplayStyle()
    showThumb()
    hideControls()
  }
  
  public func playerView(_ playerView: PlayerView, didChangedScreenMode mode: PlayerView.ScreenMode) {
    
    let isFullScreen: Bool
    switch mode {
    case .full: isFullScreen = true
    default: isFullScreen = false
    }
    screenButton.isSelected = isFullScreen
    topContainer.isHidden = !isFullScreen
  }
  
  public func playerView(_ playerView: PlayerView, updateProgressWithCurrentTime currentTime: Double, totalTime: Double) {
    
    currentTimeLabel.text = time(with: currentTime)
    totalTimeLabel.text = time(with: totalTime)
    progressSlider.value = Float(currentTime / totalTime)
  }
  
  public func playerView(_ playerView: PlayerView, updateProgressWithBufferingTime bufferingTime: Double, totalTime: Double) {
    
    bufferingProgressView.progress = Float(bufferingTime / totalTime)
    totalTimeLabel.text = time(with: totalTime)
  }
  
}

// MARK: - Setup
private extension PlayerViewDefaultControlView {
  
  func setupUI() {
    
    backgroundColor = .clear
    
    addSubview(backgroundContainer)
    backgroundContainer.layout.add { (make) in
      make.top().bottom().leading().trailing().equal(self)
    }
    
    topContainer.isHidden = true
    addSubview(topContainer)
    topContainer.layout.add { (make) in
      make.top().equal(self).safeTop()
      make.leading(25).equal(self).safeLeading()
      make.trailing(-15).equal(self).safeTrailing()
    }
    
    addSubview(bottomContainer)
    bottomContainer.layout.add { (make) in
      make.leading(25).equal(self).safeLeading()
      make.trailing(-15).equal(self).safeTrailing()
      make.bottom(-5).equal(self).safeBottom()
    }
    
    addSubview(centerContainer)
    centerContainer.layout.add { (make) in
      make.top().equal(topContainer).bottom()
      make.bottom().equal(bottomContainer).top()
      make.leading(5).trailing(-5).equal(self)
    }
    
    setupBackgroundUI()
    setupTopUI()
    setupCenterUI()
    setupBottomUI()
  }
  
  func setupBackgroundUI() {
    
    thumbView.backgroundColor = .black
    thumbView.contentMode = .scaleAspectFit
    backgroundContainer.addSubview(thumbView)
    thumbView.layout.add { (make) in
      make.top().bottom().leading().trailing().equal(backgroundContainer)
    }
  }
  
  func setupTopUI() {
    
    backButton.setImage(image(with: "back"), for: .normal)
    backButton.addTarget(self, action: #selector(clickBack), for: .touchUpInside)
    topContainer.addSubview(backButton)
    backButton.layout.add { (make) in
      make.top().bottom().leading().equal(topContainer)
      make.height(44)
    }
  }
  
  func setupCenterUI() {
    
    centerPlayStateButton.setImage(image(with: "play_big"), for: .normal)
    centerPlayStateButton.addTarget(self, action: #selector(clickPlayState), for: .touchUpInside)
    centerContainer.addSubview(centerPlayStateButton)
    centerPlayStateButton.layout.add { (make) in
      make.centerX().centerY().equal(centerContainer)
    }
  }
  
  func setupBottomUI() {
    
    setupAction(bottomPlayStateButton, normal: "play_small", selected: "pause_small")
    bottomPlayStateButton.addTarget(self, action: #selector(clickPlayState), for: .touchUpInside)
    bottomContainer.addSubview(bottomPlayStateButton)
    bottomPlayStateButton.layout.add { (make) in
      make.top().bottom().leading().equal(bottomContainer)
      make.height(30).width(30)
    }
    
    setupAction(screenButton, normal: "screen_full", selected: "screen_screen_shrink")
    screenButton.addTarget(self, action: #selector(clickScreen), for: .touchUpInside)
    bottomContainer.addSubview(screenButton)
    screenButton.layout.add { (make) in
      make.top().bottom().trailing(-15).equal(bottomContainer)
      make.height(30).width(30)
    }
    
    setupTime(currentTimeLabel)
    bottomContainer.addSubview(currentTimeLabel)
    currentTimeLabel.layout.add { (make) in
      make.leading(5).equal(bottomPlayStateButton).trailing()
      make.centerY().equal(bottomContainer)
      make.hugging(axis: .horizontal)
    }
    
    setupTime(totalTimeLabel)
    bottomContainer.addSubview(totalTimeLabel)
    totalTimeLabel.layout.add { (make) in
      make.trailing(-5).equal(screenButton).leading()
      make.centerY().equal(bottomContainer)
      make.hugging(axis: .horizontal)
    }
    
    bottomContainer.addSubview(bufferingProgressView)
    bufferingProgressView.layout.add { (make) in
      make.leading(5).equal(currentTimeLabel).trailing()
      make.trailing(-5).equal(totalTimeLabel).leading()
      make.centerY().equal(bottomContainer)
    }
    
    progressSlider.minimumTrackTintColor = UIColor(0x00f5ac)
    progressSlider.maximumTrackTintColor = .clear
    progressSlider.addTarget(self, action: #selector(slidProgress), for: .valueChanged)
    bottomContainer.addSubview(progressSlider)
    progressSlider.layout.add { (make) in
      make.leading().trailing().centerY().equal(bufferingProgressView)
    }
  }
  
  func setupGestureRecognizer() {
    
    singleTapGestureRecognizer.addTarget(self, action: #selector(singleTap))
    singleTapGestureRecognizer.numberOfTapsRequired = 1
    singleTapGestureRecognizer.numberOfTouchesRequired = 1
    centerContainer.addGestureRecognizer(singleTapGestureRecognizer)
    
    doubleTapGestureRecognizer.addTarget(self, action: #selector(doubleTap))
    doubleTapGestureRecognizer.numberOfTapsRequired = 2
    doubleTapGestureRecognizer.numberOfTouchesRequired = 1
    centerContainer.addGestureRecognizer(doubleTapGestureRecognizer)
  }
  
  func setupAction(_ button: UIButton, normal normalImage: String, selected selectedImage: String) {
    
    button.setImage(image(with: normalImage), for: .normal)
    button.setImage(image(with: selectedImage), for: .selected)
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
      
      playerView?.pause()
      return
    }
    
    playerView?.play()
  }
  
  @objc func slidProgress(_ sender: UISlider) {
    
    showControls(isAnimate: false, shouldHide: false)
    playerView?.pause()
    playerView?.seek(with: sender.value)
  }
  
  @objc func clickScreen(_ sender: UIButton) {
    
    if sender.isSelected == true {
      
      playerView?.quitFullScreen()
      return
    }
    playerView?.joinFullScreen()
  }
  
  @objc func clickBack(_ sender: UIButton) {
    
    playerView?.quitFullScreen()
  }
  
  @objc func singleTap(_ sender: UITapGestureRecognizer) {
   
    showControls(isAnimate: true, shouldHide: true)
  }
  
  @objc func doubleTap(_ sender: UITapGestureRecognizer) {
    
    clickPlayState(bottomPlayStateButton)
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
      
      bottomContainer.alpha = 1
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
      
      bottomContainer.alpha = 0
      return
    }
    
    UIView.animate(withDuration: 0.1, animations: {
      
      self.bottomContainer.alpha = 0
      
    })
  }
  
  func updatePlayingStyle() {
    
    /// 隐藏中间的播放状态按钮
    centerPlayStateButton.isHidden = true
    
    /// 暂停样式
    bottomPlayStateButton.isSelected = true
  }
  
  func updatePrepareStyle() {
    
    /// 播放样式
    centerPlayStateButton.isHidden = false
    centerPlayStateButton.setImage(image(with: "play_big"), for: .normal)
    
    /// 播放样式
    bottomPlayStateButton.isSelected = false
  }
  
  func updateReplayStyle() {
    
    centerPlayStateButton.isHidden = false
    centerPlayStateButton.setImage(image(with: "repeat_big"), for: .normal)
    
    /// 播放样式
    bottomPlayStateButton.isSelected = false
  }
  
}
