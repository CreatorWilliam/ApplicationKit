//
//  SegmentView.swift
//  ComponentKit
//
//  Created by William Lee on 2018/6/15.
//  Copyright © 2018 William Lee. All rights reserved.
//

import UIKit

/// 水平滚动的Segment控件
public class SegmentView: UIView {
  
  /// 是否可以翻页
  public var isPageEnable: Bool = true {
    
    didSet { self.collectionView.isScrollEnabled = self.isPageEnable }
  }
  /// 翻页观察者
  public weak var pageObserver: Pagable?
  /// 滑块宽度
  public var indicatorWidth: CGFloat = 50 {
    
    didSet { self.indicatorView.frame.size.width = self.indicatorWidth }
  }
  /// 滑块宽度
  public var indicatorYOffset: CGFloat = 0 {
    
    didSet { self.indicatorView.frame.origin.y += self.indicatorYOffset }
  }
  /// 滑动动画时长
  public var animationDuration: TimeInterval = 0.25
  /// 滑块颜色
  public var indicatorColor: UIColor = .blue {
    
    didSet { self.indicatorView.backgroundColor = self.indicatorColor }
  }
  /// 当前选中的索引,在初始化的时候设置，可以设置默认选中的索引
  public var selectedIndex: Int = 0
  
  private let flowLayout = UICollectionViewFlowLayout()
  private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: self.flowLayout)
  private let indicatorView = UIView()
  
  /// 段选数据源，对文字，角标，图标进行封装
  private var segments: [SegmentItem] = []
  
  public override init(frame: CGRect) {
    super.init(frame: frame)
    
    self.setupUI()
  }
  
  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  public override func layoutSubviews() {
    super.layoutSubviews()
    
    self.flowLayout.itemSize.width = self.bounds.width / CGFloat(self.segments.count > 4 ? 4 : self.segments.count)
    self.flowLayout.itemSize.height = self.bounds.height
    
    self.indicatorView.frame.origin.y = self.bounds.height - 7 + self.indicatorYOffset
    
    self.select(at: self.selectedIndex, isAnimated: false)
  }
  
}

// MARK: - Public
public extension SegmentView {
  
  func updateSegment(_ segment: SegmentItem, at index: Int) {
    
    guard index < self.segments.count else { return }
    self.segments.remove(at: index)
    self.segments.insert(segment, at: index)
    (self.collectionView.cellForItem(at: IndexPath(item: index, section: 0)) as? SegmentCell)?.update(with: segment)
  }
  
  /// 自定义SegmentItem来自定义Segment图片及文字样式
  func update(_ segments: [SegmentItem]) {
    
    self.segments = segments
    self.flowLayout.itemSize.width = self.bounds.width / CGFloat(self.segments.count > 4 ? 4 : self.segments.count)
    self.collectionView.reloadData()
    self.select(at: self.selectedIndex, isAnimated: false)
  }
  
  /// 更新指定位置的角标
  ///
  /// - Parameters:
  ///   - count: 角标显示数，nil表示隐藏，0表示小圆点，大于0显示对应的数字
  ///   - index: 要更新的Segment索引
  func updateBadge(_ count: Int?, at index: Int) {
    
    guard index < self.segments.count else { return }
    self.segments[index].badge = count
    (self.collectionView.cellForItem(at: IndexPath(item: index, section: 0)) as? SegmentCell)?.updateBadge(count)
  }
  
}

// MARK: - Pagable
extension SegmentView: Pagable {
  
  public func page(to index: Int, withSource source: Pagable) {
    
    self.select(at: index, isAnimated: true)
  }
  
}

// MARK: - Setup
private extension SegmentView {
  
  func setupUI() {
    
    self.backgroundColor = .white
    
    self.flowLayout.scrollDirection = .horizontal
    self.flowLayout.minimumLineSpacing = 0
    self.flowLayout.minimumInteritemSpacing = 0
    
    self.collectionView.delegate = self
    self.collectionView.dataSource = self
    self.collectionView.showsHorizontalScrollIndicator = false
    self.collectionView.showsVerticalScrollIndicator = false
    self.collectionView.backgroundColor = .clear
    self.collectionView.register(cells: [ReuseItem(SegmentCell.self)])
    self.addSubview(self.collectionView)
    self.collectionView.layout.add { (make) in
      
      make.top().bottom().leading().trailing().equal(self)
    }
    
    self.indicatorView.frame = .zero
    self.indicatorView.frame.size.height = 2
    self.indicatorView.frame.size.width = self.indicatorWidth
    self.indicatorView.backgroundColor = self.indicatorColor
    self.collectionView.addSubview(self.indicatorView)
  }
  
}

// MARK: - UICollectionViewDelegate
extension SegmentView: UICollectionViewDelegate {
  
  public func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
    
    self.pageObserver?.pageWillPage(at: self.selectedIndex, withSource: self)
    return true
  }
  
  public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    
    self.select(at: indexPath.item, isAnimated: true)
    self.pageObserver?.page(to: indexPath.item, withSource: self)
  }
  
}

// MARK: - UICollectionViewDataSource
extension SegmentView: UICollectionViewDataSource {
  
  public func numberOfSections(in collectionView: UICollectionView) -> Int {
    
    return 1
  }
  
  public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    
    return self.segments.count
  }
  
  public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ReuseItem(SegmentCell.self).id, for: indexPath)
    
    (cell as? SegmentCell)?.update(with: self.segments[indexPath.item])
    
    return cell
  }
  
}

// MARK: - Utility
private extension SegmentView {
  
  /// 手动选择
  func select(at index: Int, isAnimated: Bool) {
    
    guard self.segments.count > 0 else { return }
    
    self.collectionView.selectItem(at: IndexPath(item: index, section: 0), animated: true, scrollPosition: .centeredHorizontally)
    self.selectedIndex = index
    
    self.updateIndicator(at: index, isAnimated: isAnimated)
  }
  
  func updateIndicator(at index: Int, isAnimated: Bool) {
    
    // 获取偏移后的中心点X
    let centerX = self.flowLayout.itemSize.width * CGFloat(index) + self.flowLayout.itemSize.width * 0.5
    
    // 无动画
    if isAnimated == false {
      
      self.indicatorView.center.x = centerX
      return
    }
    
    // 有动画
    UIView.animate(withDuration: self.animationDuration, animations: {
      
      self.indicatorView.center.x = centerX
      
    }, completion: { (_) in
      
      self.pageObserver?.pageDidPage(to: self.selectedIndex, withSource: self)
    })
  }
  
}
