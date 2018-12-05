//
//  PageView.swift
//  ComponentKit
//
//  Created by William Lee on 2018/6/15.
//  Copyright © 2018 William Lee. All rights reserved.
//

import UIKit

/// 目前仅支持水平滚动翻页
public class PageView: UIView {
  
  /// 是否可以翻页
  public var isPageEnable: Bool = true {
    
    didSet { self.pageScrollView.isScrollEnabled = self.isPageEnable }
  }
  /// 滚动动画时长
  public var animationDuration: TimeInterval = 0.25
  /// 翻页观察者
  public weak var pageObserver: Pagable?
  
  /// 根据当前滚动视图x偏移与视图宽度计算
  public var currentIndex: Int = 0
  /// 滚动视图
  private let pageScrollView = UIScrollView()
  /// 自定义的页面视图
  private var pageViews: [UIView] = []
  
  /// 是否同通知代理，目前是为了解决外部触发的翻页事件，会再次触发内部的翻页事件
  private var shouldNotifyDelegate: Bool = true
  
  public override init(frame: CGRect) {
    super.init(frame: frame)
    
    self.setupUI()
  }
  
  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  public override func layoutSubviews() {
    super.layoutSubviews()
    
    self.pageScrollView.contentOffset.x = CGFloat(self.currentIndex) * self.pageScrollView.bounds.width
  }
}

// MARK: - Public
public extension PageView {
  
  /// 设置页面
  ///
  /// - Parameter pages: 页面数组
  func updatePages(_ pageViews: [UIView]) {

    self.pageViews = pageViews
    self.pageViews.enumerated().forEach({ (index, pageView) in

      let previousPageView = (index == 0 ? nil : self.pageViews[index - 1])
      let nextPageView = (index == self.pageViews.count - 1) ? nil : self.pageViews[index + 1]
      self.pageScrollView.addSubview(pageView)
      pageView.layout.add({ (make) in

        if let previousView = previousPageView {

          make.leading().equal(previousView).trailing()

        } else {

          make.leading().equal(self.pageScrollView)
        }

        if nextPageView == nil {

          make.trailing().equal(self.pageScrollView)
        }
        make.width().height().top().bottom().equal(self.pageScrollView)
      })
    })
    
  }
  
}

// MARK: - Pagable
extension PageView: Pagable {
  
  public func page(to index: Int, withSource source: Pagable) {
    
    // 警告：该方式会触发scrollViewDidEndScrollingAnimation，从而会通知self.pageObserver，容易造成循环通知
    //self.pageScrollView.setContentOffset(CGPoint(x: CGFloat(index) * self.pageScrollView.bounds.width, y: 0), animated: true)
    
    // 事实上，这种滚动也会触发scrollViewDidEndScrollingAnimation，从而会通知self.pageObserver，容易造成循环通知
    // ORZ，So 使用一个属性进行区分
    // 手动生成滚动动画
    self.shouldNotifyDelegate = false
    self.pageObserver?.pageWillPage(at: index, withSource: self)
    
    UIView.animate(withDuration: self.animationDuration, animations: {

      self.pageScrollView.contentOffset.x = CGFloat(index) * self.pageScrollView.bounds.width

    }, completion: { (_) in

      self.pageObserver?.pageDidPage(to: index, withSource: self)
      self.currentIndex = index
      self.shouldNotifyDelegate = true
    })
  }
  
}

// MARK: - Setup
private extension PageView {
  
  func setupUI() {
  
    self.pageScrollView.delegate = self
    self.pageScrollView.isPagingEnabled = true
    self.pageScrollView.bounces = false
    self.pageScrollView.showsVerticalScrollIndicator = false
    self.pageScrollView.showsHorizontalScrollIndicator = false
    self.addSubview(self.pageScrollView)
    self.pageScrollView.layout.add { (make) in
      make.top().bottom().leading().trailing().equal(self)
    }
  
  }
  
}

// MARK: - UIScrollViewDelegate
extension PageView: UIScrollViewDelegate {
  
  public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
    
    guard scrollView.bounds.width > 0 else { return }
    let index = Int((self.pageScrollView.contentOffset.x + self.pageScrollView.bounds.width / 2.0) / self.pageScrollView.bounds.width)
    self.pageObserver?.pageWillPage(at: index, withSource: self)
  }
  
  public func scrollViewDidScroll(_ scrollView: UIScrollView) {
    
    guard scrollView.bounds.width > 0 && self.shouldNotifyDelegate == true else { return }
    let index = Int((self.pageScrollView.contentOffset.x + self.pageScrollView.bounds.width / 2.0) / self.pageScrollView.bounds.width)
    self.pageObserver?.page(to: index, withSource: self)
  }
  
  public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
    
    guard scrollView.bounds.width > 0 else { return }
    let index = Int((self.pageScrollView.contentOffset.x + self.pageScrollView.bounds.width / 2.0) / self.pageScrollView.bounds.width)
    self.pageObserver?.pageDidPage(to: index, withSource: self)
  }
  
}
