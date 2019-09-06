//
//  SegmentView.swift
//  ComponentKit
//
//  Created by William Lee on 2018/6/15.
//  Copyright © 2018 William Lee. All rights reserved.
//

import ApplicationKit
import UIKit

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
    didSet { collectionView.register(cells: [segmentCell])}
  }
  /// 设置最大可见Segment个数，默认为4，该值会计算单个Segment的宽度，若计算所得的宽度小于minVisibleWidth，则使用minVisibleWidth的值
  public var maxVisibleCount: CGFloat = 4
  /// 设置最小Segment宽度，默认为0，无限制
  public var minSegmentWidth: CGFloat = 0
  /// 是否可以翻页
  public var isPageEnable: Bool = true {
    
    didSet { collectionView.isScrollEnabled = isPageEnable }
  }
  /// 翻页观察者
  public weak var pageObserver: Pagable?
  /// 滑块宽度
  public var indicatorWidth: CGFloat = 50 {
    
    didSet { indicatorView.frame.size.width = indicatorWidth }
  }
  /// 滑块Y方向向下偏移的修正量，默认为0，通过计算后会向上偏移5个pt单位
  public var indicatorYOffset: CGFloat = 0 {
    
    didSet { indicatorView.frame.origin.y += indicatorYOffset }
  }
  /// 滑块颜色
  public var indicatorColor: UIColor = .blue {
    
    didSet { indicatorView.backgroundColor = indicatorColor }
  }
  /// 滑动动画时长
  public var animationDuration: TimeInterval = 0.25
  /// 当前选中的索引,在初始化的时候设置，可以设置默认选中的索引
  public var selectedIndex: Int = 0
  
  // MARK: ********** Private **********
  private let flowLayout = UICollectionViewFlowLayout()
  private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
  private let indicatorView = UIView()
  
  /// 段选数据源，对文字，角标，图标进行封装
  private var segments: [SegmentViewItemSourcable] = []
  
  public override init(frame: CGRect) {
    super.init(frame: frame)
    
    setupUI()
  }
  
  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  public override func layoutSubviews() {
    super.layoutSubviews()
    
    /// 根据元素个数及最大显示个数来计算宽度
    flowLayout.itemSize.width = bounds.width / min(CGFloat(segments.count), CGFloat(maxVisibleCount))
    /// 若计算的宽度小于最小宽度，则使用最小宽度
    if flowLayout.itemSize.width < minSegmentWidth {
      flowLayout.itemSize.width = minSegmentWidth
    }
    flowLayout.itemSize.height = bounds.height
    
    indicatorView.frame.origin.y = (bounds.height - 7 + indicatorYOffset)
    
    select(at: selectedIndex, isAnimated: false)
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
    
    guard index < segments.count else { return }
    segments.remove(at: index)
    segments.insert(item, at: index)
    (collectionView.cellForItem(at: IndexPath(item: index, section: 0)) as? SegmentViewCellable)?.update(with: item)
  }
  
  /// 使用数据源更新SegmentView
  ///
  /// - Parameter segments: 数据源，内置SegmentViewItem已遵循该协议
  func update(with segments: [SegmentViewItemSourcable]) {
    
    self.segments = segments
    flowLayout.itemSize.width = bounds.width / (CGFloat(segments.count) > maxVisibleCount ? maxVisibleCount : CGFloat(segments.count))
    collectionView.reloadData()
    select(at: selectedIndex, isAnimated: false)
    indicatorView.isHidden = !(segments.count > 0)
  }
  
  /// 更新指定位置的角标，如果使用自定义的SegmentViewCell，则需要遵循SegmentViewCellBadgable，才可以设置角标
  ///
  /// - Parameters:
  ///   - count: 角标显示数，nil表示隐藏，0表示小圆点，大于0显示对应的数字
  ///   - index: 要更新的Segment索引
  func updateBadge(_ count: Int?, at index: Int) {
    
    guard index < segments.count else { return }
    (collectionView.cellForItem(at: IndexPath(item: index, section: 0)) as? SegmentViewCellBadgable)?.updateBadge(count)
  }
  
}

// MARK: - Pagable
extension SegmentView: Pagable {
  
  public func page(to index: Int, withSource source: Pagable) {
    
    select(at: index, isAnimated: true)
  }
  
}

// MARK: - Setup
private extension SegmentView {
  
  func setupUI() {
    
    backgroundColor = .white
    
    flowLayout.scrollDirection = .horizontal
    flowLayout.minimumLineSpacing = 0
    flowLayout.minimumInteritemSpacing = 0
    
    collectionView.delegate = self
    collectionView.dataSource = self
    collectionView.showsHorizontalScrollIndicator = false
    collectionView.showsVerticalScrollIndicator = false
    collectionView.backgroundColor = .clear
    collectionView.register(cells: [ReuseItem(SegmentViewCell.self)])
    addSubview(collectionView)
    collectionView.layout.add { (make) in
      make.top().bottom().leading().trailing().equal(self)
    }
    
    indicatorView.frame = .zero
    indicatorView.frame.size.height = 2
    indicatorView.frame.size.width = indicatorWidth
    indicatorView.backgroundColor = indicatorColor
    collectionView.addSubview(indicatorView)
    indicatorView.isHidden = true
  }
  
}

// MARK: - UICollectionViewDelegate
extension SegmentView: UICollectionViewDelegate {
  
  public func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
    
    pageObserver?.pageWillPage(at: selectedIndex, withSource: self)
    return true
  }
  
  public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    
    select(at: indexPath.item, isAnimated: true)
    pageObserver?.page(to: indexPath.item, withSource: self)
  }
  
}

// MARK: - UICollectionViewDataSource
extension SegmentView: UICollectionViewDataSource {
  
  public func numberOfSections(in collectionView: UICollectionView) -> Int {
    
    return 1
  }
  
  public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    
    return segments.count
  }
  
  public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: segmentCell.id, for: indexPath)
    
    (cell as? SegmentViewCellable)?.update(with: segments[indexPath.item])
    
    return cell
  }
  
}

// MARK: - Utility
private extension SegmentView {
  
  /// 手动选择
  func select(at index: Int, isAnimated: Bool) {
    
    guard segments.count > 0 else { return }
    
    collectionView.selectItem(at: IndexPath(item: index, section: 0), animated: true, scrollPosition: .centeredHorizontally)
    selectedIndex = index
    
    updateIndicator(at: index, isAnimated: isAnimated)
  }
  
  func updateIndicator(at index: Int, isAnimated: Bool) {
    
    // 获取偏移后的中心点X
    let centerX = flowLayout.itemSize.width * CGFloat(index) + flowLayout.itemSize.width * 0.5
    
    // 无动画
    if isAnimated == false {
      
      indicatorView.center.x = centerX
      return
    }
    
    // 有动画
    UIView.animate(withDuration: animationDuration, animations: {
      
      self.indicatorView.center.x = centerX
      
    }, completion: { (_) in
      
      self.pageObserver?.pageDidPage(to: self.selectedIndex, withSource: self)
    })
  }
  
}
