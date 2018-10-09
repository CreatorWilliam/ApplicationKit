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
  
  func didSelect(at index: Int)
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
    
    var index = self.currentIndex - 1
    if index < 0 { index = self.items.count - 1 }
    return index
  }
  /// 下一个
  private var nextIndex: Int {
    
    var index = self.currentIndex + 1
    if index > self.items.count - 1 { index = 0 }
    return index
  }
  
  /// 是否自动滚动
  private var isAutoScrollable: Bool = false
  /// 数据源
  private var items: [Any] = []
  
  public init(frame: CGRect = .zero,
              isAutoScrollable: Bool = false) {
    super.init(frame: frame)
    
    self.isAutoScrollable = isAutoScrollable
    
    self.setupUI()
  }
  
  required public init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  public override func layoutSubviews() {
    super.layoutSubviews()
    
    self.scrollView.frame = self.bounds
    
    let width: CGFloat = self.scrollView.bounds.width
    let height: CGFloat = self.scrollView.bounds.height
    
    switch self.direction {
    case .horizontal:
      
      self.previousView.frame = CGRect(x: 0, y: 0, width: width, height: height)
      self.currentView.frame = CGRect(x: width, y: 0, width: width, height: height)
      self.nextView.frame = CGRect(x: width * 2, y: 0, width: width, height: height)
      self.scrollView.contentSize = CGSize(width: width * 3, height: height)
      self.scrollView.contentOffset = CGPoint(x: width, y: 0)
      
    case .vertical:
      
      self.previousView.frame = CGRect(x: 0, y: 0, width: width, height: height)
      self.currentView.frame = CGRect(x: 0, y: height, width: width, height: height)
      self.nextView.frame = CGRect(x: 0, y: height * 2, width: width, height: height)
      self.scrollView.contentSize = CGSize(width: width, height: height * 3)
      self.scrollView.contentOffset = CGPoint(x: 0, y: height)
    }
    
  }
}

// MARK: - Public
public extension CircleScrollView {
  
  /// 设置轮播图集后，自动进行轮播
  ///
  /// - Parameter items: 轮播图集
  func update(with items: [Any]) {
    
    //保存数据,只会初始化一次
    if self.items.count > 0 { return }
    self.items = items
    self.currentIndex = 0
    self.pageControl.numberOfPages = self.items.count
    
    // 防止越界
    guard self.items.count > 0 else { return }
    self.scrollView.isScrollEnabled = (self.items.count > 1)
    self.update(view: self.previousView, with: self.items[self.previousIndex])
    self.update(view: self.currentView, with: self.items[self.currentIndex])
    self.update(view: self.nextView, with: self.items[self.nextIndex])
    
    //判断启动轮播
    if self.isAutoScrollable {
      
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
    
    self.updateContent()
  }
  
  //  public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
  //
  //    switch self.direction {
  //    case .horizontal:
  //
  //      if velocity.x > 0 { self.scrollToNext() }
  //      else if velocity.x < 0 { self.scrollToPrevious() }
  //      else { return }
  //
  //    case .vertical:
  //
  //      if velocity.y > 0 { self.scrollToNext() }
  //      else if velocity.y < 0 { self.scrollToPrevious() }
  //      else { return }
  //
  //    }
  //
  //  }
  
}

// MARK: - Zoomable
extension CircleScrollView: Zoomable {
  
  public var zoomView: UIView { return self.currentView }
  
  public var zoomViewContainer: UIView { return self.scrollView }
  
  public func zoom(with offset: CGFloat) {
    
    // 仅支持水平滚动，竖直方向上放大
    guard self.direction == .horizontal else { return }
    
    let size = self.scrollView.bounds.size
    
    guard size.height > 0 else { return }
    self.zoomView.layer.anchorPoint = CGPoint(x: 0.5, y: 1)
    self.zoomView.center = CGPoint(x: self.scrollView.contentSize.width / 2, y: self.scrollView.contentSize.height)
    
    
    //向下偏移放大
    if (offset > 0) { return }
    
    let heightOffset = abs(offset)
    let widhtOffset = abs(offset) * (size.width / size.height)
    
    self.zoomView.bounds.size.height = heightOffset + size.height
    self.zoomView.bounds.size.width = widhtOffset + size.width
  }
  
}

// MARK: - Setup
private extension CircleScrollView {
  
  func setupUI() {
    
    //ScrollView
    self.scrollView.clipsToBounds = false
    self.scrollView.showsVerticalScrollIndicator = false
    self.scrollView.showsHorizontalScrollIndicator = false
    self.scrollView.delegate = self
    self.scrollView.bounces = true
    self.scrollView.isPagingEnabled = true
    self.scrollView.backgroundColor = .clear
    self.addSubview(self.scrollView)
    
    self.previousView.contentMode = .scaleAspectFill
    self.previousView.clipsToBounds = true
    self.scrollView.addSubview(self.previousView)
    
    self.currentView.contentMode = .scaleAspectFill
    self.currentView.clipsToBounds = true
    self.scrollView.addSubview(self.currentView)
    
    self.nextView.contentMode = .scaleAspectFill
    self.nextView.clipsToBounds = true
    self.scrollView.addSubview(self.nextView)
    
    self.pageControl.isUserInteractionEnabled = false
    self.pageControl.hidesForSinglePage = true
    self.addSubview(self.pageControl)
    self.pageControl.layout.add { (make) in
      
      make.leading().trailing().bottom().equal(self)
    }
    let tapGR = UITapGestureRecognizer()
    tapGR.numberOfTapsRequired = 1
    tapGR.numberOfTouchesRequired = 1
    tapGR.addTarget(self, action: #selector(clickContent(_:)))
    self.addGestureRecognizer(tapGR)
  }
  
}

// MARK: - Action
private extension CircleScrollView {
  
  @objc func clickContent(_ sender: Any) {
    
    self.delegate?.didSelect(at: self.currentIndex)
  }
  
  /// 开始循环
  func startLoop() {
    
    //大于1，轮播，否则不轮播
    guard self.items.count > 1 else {
      
      self.stopLoop()
      return
    }
    
    //已经启动则不再重新启动
    if let _ = self.timer { return }
    
    //正常启动
    self.timer = Timer(timeInterval: 5, target: self, selector: #selector(loop), userInfo: nil, repeats: true)
    guard let temp = self.timer else { return }
    RunLoop.main.add(temp, forMode: RunLoop.Mode.default)
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
      
      self.timer?.fire()
    }
    
  }
  
  /// 停止循环
  func stopLoop() {
    
    self.timer?.invalidate()
    self.timer = nil
  }
  
  @objc func loop(_ timer: Timer) {
    
    self.scrollToNext()
  }
  
  func scrollToPrevious() {
    
    var offset: CGPoint = .zero
    switch self.direction {
    case .horizontal: offset.x = 0
    case .vertical: offset.y = 0
    }
    
    self.scrollView.isUserInteractionEnabled = false
    UIView.animate(withDuration: 0.5, animations: {
      
      self.scrollView.contentOffset = offset
      
    }, completion: { (_) in
      
      self.scrollView.isUserInteractionEnabled = true
      self.updateContent()
    })
    
  }
  
  func scrollToNext() {
    
    var offset: CGPoint = .zero
    switch self.direction {
    case .horizontal: offset.x = self.scrollView.bounds.width * 2
    case .vertical: offset.y = self.scrollView.bounds.height * 2
    }
    
    self.scrollView.isUserInteractionEnabled = false
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
    
    self.pageControl.currentPage = self.currentIndex
    
    var offset: CGPoint = .zero
    
    var isPrevious: Bool = false
    var isNext: Bool = false
    
    switch self.direction {
    case .horizontal:
      
      let width: CGFloat = self.scrollView.bounds.width
      offset = CGPoint(x: width, y: 0)
      if self.scrollView.contentOffset.x < width { isPrevious = true }
      if self.scrollView.contentOffset.x > width { isNext = true }
      
    case .vertical:
      
      let height: CGFloat = self.scrollView.bounds.height
      offset = CGPoint(x: 0, y: height)
      if self.scrollView.contentOffset.y < height { isPrevious = true }
      if self.scrollView.contentOffset.y > height { isNext = true }
    }
    
    if isPrevious == true {
      
      // 更新索引
      self.currentIndex -= 1
      if self.currentIndex < 0 { self.currentIndex = self.items.count - 1 }
      // 交换位置
      (self.previousView, self.currentView) = (self.currentView, self.previousView)
      (self.previousView.frame, self.currentView.frame) = (self.currentView.frame, self.previousView.frame)
      
    } else if isNext == true {
      
      // 更新索引
      self.currentIndex += 1
      if self.currentIndex > self.items.count - 1 { self.currentIndex = 0 }
      // 交换位置
      (self.currentView, self.nextView) = (self.nextView, self.currentView)
      (self.currentView.frame, self.nextView.frame) = (self.nextView.frame, self.currentView.frame)
      
    } else {
      
      return
    }
    
    self.scrollView.contentOffset = offset
    
    guard self.previousIndex < self.items.count else { return }
    guard self.nextIndex < self.items.count else { return }
    self.update(view: self.previousView, with: self.items[self.previousIndex])
    self.update(view: self.nextView, with: self.items[self.nextIndex])
    
  }
  
  func update(view:  UIView, with content: Any) {
    
    guard let imageView = view as? UIImageView else { return }
    if let urlString = content as? String {
      
      guard let url = URL(string: urlString) else { return }
      imageView.setImage(with: url)
      
    } else if let image = content as? UIImage {
      
      imageView.image = image
      
    } else {
      
      // Nothing
    }
    
  }
  
}








