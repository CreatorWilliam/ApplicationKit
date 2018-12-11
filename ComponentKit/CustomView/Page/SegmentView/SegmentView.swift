//
//  SegmentView.swift
//  ComponentKit
//
//  Created by William Lee on 2018/6/15.
//  Copyright © 2018 William Lee. All rights reserved.
//

import ApplicationKit

/// 遵循了该协议的UICollectionViewCell，SegmentView中自定义的Cell才会接收更新数据源的事件
public protocol SegmentViewCellable {
  
  /// 更新Cell内容
  ///
  /// - Parameter item: 填充Cell内容的数据
  func update(with item: SegmentViewItemSourcable)
}

/// 遵循了该协议，SegmentView中自定义的Cell才会接收更新角标的事件
public protocol SegmentViewCellBadgable {
  
  /// 更新角标
  ///
  /// - Parameter count: 角标显示数，nil表示隐藏，0表示小圆点，大于0显示对应的数字
  func updateBadge(_ count: Int?)
}

/// 遵循了该协议才能作为SegmentView的数据源元素,可以使用已有的SegmentViewItem
public protocol SegmentViewItemSourcable {
  
}

/// 水平滚动的Segment控件
public class SegmentView: UIView {
  
  // MARK: ********** Public **********
  /// 用于自定义SegmentView中Cell的样式
  ///
  /// 其中Cell必须为UICollectionViewCell或其子类，且遵循了SegmentViewCellable协议
  ///
  /// 若遵循SegmentViewCellBadgable，则可以进行角标设置
  public var segmentCell: ReuseItem = ReuseItem(SegmentViewCell.self) {
    didSet { self.collectionView.register(cells: [self.segmentCell])}
  }
  /// 设置最大可见Segment个数，默认为4
  public var maxVisibleCount: CGFloat = 4
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
  /// 滑块颜色
  public var indicatorColor: UIColor = .blue {
    
    didSet { self.indicatorView.backgroundColor = self.indicatorColor }
  }
  /// 滑动动画时长
  public var animationDuration: TimeInterval = 0.25
  /// 当前选中的索引,在初始化的时候设置，可以设置默认选中的索引
  public var selectedIndex: Int = 0
  
  // MARK: ********** Private **********
  private let flowLayout = UICollectionViewFlowLayout()
  private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: self.flowLayout)
  private let indicatorView = UIView()
  
  /// 段选数据源，对文字，角标，图标进行封装
  private var segments: [SegmentViewItemSourcable] = []
  
  public override init(frame: CGRect) {
    super.init(frame: frame)
    
    self.setupUI()
  }
  
  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  public override func layoutSubviews() {
    super.layoutSubviews()
    
    self.flowLayout.itemSize.width = self.bounds.width / (CGFloat(self.segments.count) > self.maxVisibleCount ? self.maxVisibleCount : CGFloat(self.segments.count))
    self.flowLayout.itemSize.height = self.bounds.height
    
    self.indicatorView.frame.origin.y = self.bounds.height - 7 + self.indicatorYOffset
    
    self.select(at: self.selectedIndex, isAnimated: false)
  }
  
}

// MARK: - Public
public extension SegmentView {
  
  /// 更新指定位置的Segment
  ///
  /// - Parameters:
  ///   - item: 数据源，内置SegmentViewItem已遵循该协议
  ///   - index: 位置索引
  func updateSegment(with item: SegmentViewItemSourcable, at index: Int) {
    
    guard index < self.segments.count else { return }
    self.segments.remove(at: index)
    self.segments.insert(item, at: index)
    (self.collectionView.cellForItem(at: IndexPath(item: index, section: 0)) as? SegmentViewCellable)?.update(with: item)
  }
  
  /// 使用数据源更新SegmentView
  ///
  /// - Parameter segments: 数据源，内置SegmentViewItem已遵循该协议
  func update(with segments: [SegmentViewItemSourcable]) {
    
    self.segments = segments
    self.flowLayout.itemSize.width = self.bounds.width / (CGFloat(self.segments.count) > self.maxVisibleCount ? self.maxVisibleCount : CGFloat(self.segments.count))
    self.collectionView.reloadData()
    self.select(at: self.selectedIndex, isAnimated: false)
  }
  
  /// 更新指定位置的角标，如果使用自定义的SegmentViewCell，则需要遵循SegmentViewCellBadgable，才可以设置角标
  ///
  /// - Parameters:
  ///   - count: 角标显示数，nil表示隐藏，0表示小圆点，大于0显示对应的数字
  ///   - index: 要更新的Segment索引
  func updateBadge(_ count: Int?, at index: Int) {
    
    guard index < self.segments.count else { return }
    (self.collectionView.cellForItem(at: IndexPath(item: index, section: 0)) as? SegmentViewCellBadgable)?.updateBadge(count)
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
    self.collectionView.register(cells: [ReuseItem(SegmentViewCell.self)])
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
    
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: self.segmentCell.id, for: indexPath)
    
    (cell as? SegmentViewCellable)?.update(with: self.segments[indexPath.item])
    
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
