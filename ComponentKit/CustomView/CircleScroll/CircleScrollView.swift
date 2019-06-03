//
//  CircleScrollView.swift
//  ComponentKit
//
//  Created by William Lee on 20/12/17.
//  Copyright © 2018 William Lee. All rights reserved.
//

import UIKit
import ImageKit

public protocol CircleScrollViewDelegate: class {
  
  func circleScrollView(_ view: CircleScrollView, didScrollTo index: Int)
  func circleScrollView(_ view: CircleScrollView, didSelectAt index: Int)
}

// MARK: - Default
public extension CircleScrollViewDelegate {
  
  func circleScrollView(_ view: CircleScrollView, didScrollTo index: Int) { }
}

public class CircleScrollView: UIView {
  
  /// 滑动方向
  public enum Direction {
    /// 水平滑动
    case horizontal
    /// 竖直滑动
    case vertical
  }
  
  public weak var delegate: CircleScrollViewDelegate?
  /// 页码
  public let pageControl = UIPageControl()
  /// 占位图(本地图片名)
  public var placeholder: String? {
    didSet {
      
      if let name = placeholder {
        
        previousView.image = UIImage(named: name)
        currentView.image = UIImage(named: name)
        nextView.image = UIImage(named: name)
      }
    }
  }
  
  /// 滑动方向
  private var direction: Direction = .horizontal
  /// 展示内容的容器
  private let scrollView: UIScrollView = UIScrollView()
  /// 上一个视图
  private var previousView = UIImageView()
  /// 当前视图
  private var currentView = UIImageView()
  /// 下一个视图
  private var nextView = UIImageView()
  
  //Timer
  private var timer: Timer?
  
  /// 当前索引
  private var currentIndex: Int = 0
  /// 上一个
  private var previousIndex: Int {
    
    var index = currentIndex - 1
    if index < 0 { index = images.count - 1 }
    return index
  }
  /// 下一个
  private var nextIndex: Int {
    
    var index = currentIndex + 1
    if index > images.count - 1 { index = 0 }
    return index
  }
  
  /// 是否自动滚动
  private var isAutoScrollable: Bool = false
  /// 数据源
  private var images: [Any] = []
  
  public init(frame: CGRect = .zero,
              isAutoScrollable: Bool = false) {
    super.init(frame: frame)
    
    self.isAutoScrollable = isAutoScrollable
    
    setupUI()
  }
  
  required public init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  public override func layoutSubviews() {
    super.layoutSubviews()
    
    scrollView.frame = bounds
    
    let width: CGFloat = scrollView.bounds.width
    let height: CGFloat = scrollView.bounds.height
    
    switch direction {
    case .horizontal:
      
      previousView.frame = CGRect(x: 0, y: 0, width: width, height: height)
      currentView.frame = CGRect(x: width, y: 0, width: width, height: height)
      nextView.frame = CGRect(x: width * 2, y: 0, width: width, height: height)
      scrollView.contentSize = CGSize(width: width * 3, height: height)
      scrollView.contentOffset = CGPoint(x: width, y: 0)
      
    case .vertical:
      
      previousView.frame = CGRect(x: 0, y: 0, width: width, height: height)
      currentView.frame = CGRect(x: 0, y: height, width: width, height: height)
      nextView.frame = CGRect(x: 0, y: height * 2, width: width, height: height)
      scrollView.contentSize = CGSize(width: width, height: height * 3)
      scrollView.contentOffset = CGPoint(x: 0, y: height)
    }
    
  }
}

// MARK: - Public
public extension CircleScrollView {
  
  /// 设置轮播图集后，自动进行轮播
  ///
  /// - Parameter items: 轮播图集
  func update(with items: [Any], isForce: Bool = false) {
    
    //保存数据,只会初始化一次, 除非是强制性更新
    if images.count > 0 && isForce == false { return }
    images = items
    currentIndex = 0
    pageControl.numberOfPages = images.count
    
    // 防止越界
    guard images.count > 0 else { return }
    scrollView.isScrollEnabled = (images.count > 1)
    update(view: previousView, with: images[previousIndex])
    update(view: currentView, with: images[currentIndex])
    update(view: nextView, with: images[nextIndex])
    
    //判断启动轮播
    if isAutoScrollable {
      
      DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
        
        self.startLoop()
      })
      
    } else {
      
      self.stopLoop()
    }
  }
  
}

// MARK: - UIScrollViewDelegate
extension CircleScrollView: UIScrollViewDelegate {
  
  public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    
    updateContent()
  }
  
}

// MARK: - Zoomable
extension CircleScrollView: Zoomable {
  
  public var zoomView: UIView { return currentView }
  
  public var zoomViewContainer: UIView { return scrollView }
  
  public func zoom(with offset: CGFloat) {
    
    // 仅支持水平滚动，竖直方向上放大
    guard direction == .horizontal else { return }
    
    let size = scrollView.bounds.size
    
    guard size.height > 0 else { return }
    zoomView.layer.anchorPoint = CGPoint(x: 0.5, y: 1)
    zoomView.center = CGPoint(x: scrollView.contentSize.width / 2, y: scrollView.contentSize.height)
    
    
    //向下偏移放大
    if (offset > 0) { return }
    
    let heightOffset = abs(offset)
    let widhtOffset = abs(offset) * (size.width / size.height)
    
    zoomView.bounds.size.height = heightOffset + size.height
    zoomView.bounds.size.width = widhtOffset + size.width
  }
  
}

// MARK: - Setup
private extension CircleScrollView {
  
  func setupUI() {
    
    //ScrollView
    scrollView.clipsToBounds = false
    scrollView.showsVerticalScrollIndicator = false
    scrollView.showsHorizontalScrollIndicator = false
    scrollView.delegate = self
    scrollView.bounces = true
    scrollView.isPagingEnabled = true
    scrollView.backgroundColor = .clear
    scrollView.isScrollEnabled = false
    addSubview(scrollView)
    
    previousView.contentMode = .scaleAspectFill
    previousView.clipsToBounds = true
    scrollView.addSubview(previousView)
    
    currentView.contentMode = .scaleAspectFill
    currentView.clipsToBounds = true
    scrollView.addSubview(currentView)
    
    nextView.contentMode = .scaleAspectFill
    nextView.clipsToBounds = true
    scrollView.addSubview(nextView)
    
    pageControl.isUserInteractionEnabled = false
    pageControl.hidesForSinglePage = true
    addSubview(pageControl)
    pageControl.layout.add { (make) in
      
      make.leading().trailing().bottom().equal(self)
    }
    let tapGR = UITapGestureRecognizer()
    tapGR.numberOfTapsRequired = 1
    tapGR.numberOfTouchesRequired = 1
    tapGR.addTarget(self, action: #selector(clickContent(_:)))
    addGestureRecognizer(tapGR)
  }
  
}

// MARK: - Action
private extension CircleScrollView {
  
  @objc func clickContent(_ sender: Any) {
    
    guard images.count > 0 else { return }
    delegate?.circleScrollView(self, didSelectAt: currentIndex)
  }
  
  /// 开始循环
  func startLoop() {
    
    //大于1，轮播，否则不轮播
    guard images.count > 1 else {
      
      stopLoop()
      return
    }
    
    //已经启动则不再重新启动
    if let _ = timer { return }
    
    //正常启动
    timer = Timer(timeInterval: 5, target: self, selector: #selector(loop), userInfo: nil, repeats: true)
    guard let temp = timer else { return }
    RunLoop.main.add(temp, forMode: RunLoop.Mode.default)
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
      
      self.timer?.fire()
    }
    
  }
  
  /// 停止循环
  func stopLoop() {
    
    timer?.invalidate()
    timer = nil
  }
  
  @objc func loop(_ timer: Timer) {
    
    scrollToNext()
  }
  
  func scrollToPrevious() {
    
    var offset: CGPoint = .zero
    switch direction {
    case .horizontal: offset.x = 0
    case .vertical: offset.y = 0
    }
    
    scrollView.isUserInteractionEnabled = false
    UIView.animate(withDuration: 0.5, animations: {
      
      self.scrollView.contentOffset = offset
      
    }, completion: { (_) in
      
      self.scrollView.isUserInteractionEnabled = true
      self.updateContent()
    })
    
  }
  
  func scrollToNext() {
    
    var offset: CGPoint = .zero
    switch direction {
    case .horizontal: offset.x = scrollView.bounds.width * 2
    case .vertical: offset.y = scrollView.bounds.height * 2
    }
    
    scrollView.isUserInteractionEnabled = false
    UIView.animate(withDuration: 0.5, animations: {
      
      self.scrollView.contentOffset = offset
      
    }, completion: { (_) in
      
      self.scrollView.isUserInteractionEnabled = true
      self.updateContent()
    })
    
  }
  
}

// MARK: - Utility
private extension CircleScrollView {
  
  func updateContent() {
    
    defer {
      
      pageControl.currentPage = currentIndex
      delegate?.circleScrollView(self, didScrollTo: currentIndex)
    }
    
    var offset: CGPoint = .zero
    
    var isPrevious: Bool = false
    var isNext: Bool = false
    
    switch direction {
    case .horizontal:
      
      let width: CGFloat = scrollView.bounds.width
      offset = CGPoint(x: width, y: 0)
      if scrollView.contentOffset.x < width { isPrevious = true }
      if scrollView.contentOffset.x > width { isNext = true }
      
    case .vertical:
      
      let height: CGFloat = scrollView.bounds.height
      offset = CGPoint(x: 0, y: height)
      if scrollView.contentOffset.y < height { isPrevious = true }
      if scrollView.contentOffset.y > height { isNext = true }
    }
    
    if isPrevious == true {
      
      // 更新索引
      currentIndex -= 1
      if currentIndex < 0 { currentIndex = images.count - 1 }
      // 交换位置
      (previousView, currentView) = (currentView, previousView)
      (previousView.frame, currentView.frame) = (currentView.frame, previousView.frame)
      
    } else if isNext == true {
      
      // 更新索引
      currentIndex += 1
      if currentIndex > images.count - 1 { currentIndex = 0 }
      // 交换位置
      (currentView, nextView) = (nextView, currentView)
      (currentView.frame, nextView.frame) = (nextView.frame, currentView.frame)
      
    } else {
      
      return
    }
    
    scrollView.contentOffset = offset
    
    guard previousIndex < images.count else { return }
    guard nextIndex < images.count else { return }
    update(view: previousView, with: images[previousIndex])
    update(view: nextView, with: images[nextIndex])
    
  }
  
  func update(view: UIView, with content: Any) {
    
    guard let imageView = view as? UIImageView else { return }
    
    if let url = content as? String {
      
      imageView.setImage(with: url, placeholder: placeholder)
      
    } else if let image = content as? UIImage {
      
      imageView.image = image
      
    } else if let url = content as? URL {
      
      imageView.setImage(with: url, placeholder: placeholder)
      
    } else {
      
      // Nothing
    }
    
  }
  
}
