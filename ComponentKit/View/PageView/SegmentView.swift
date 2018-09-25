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
  /// 滑动动画时长
  public var animationDuration: TimeInterval = 0.25
  /// 滑块颜色
  public var indicatorColor: UIColor = .blue {
    
    didSet { self.indicatorView.backgroundColor = self.indicatorColor }
  }
  /// 根据当前选中的部分获得
  public var currentIndex: Int { return self.collectionView.indexPathsForSelectedItems?.first?.item ?? -1 }
  
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
    
    self.indicatorView.frame.origin.y = self.bounds.height - 7
    
    self.flowLayout.itemSize.width = self.bounds.width / CGFloat(self.segments.count > 4 ? 4 : self.segments.count)
    self.flowLayout.itemSize.height = self.bounds.height
  }
  
}

// MARK: - Public
public extension SegmentView {
  
  func updateSegment(_ segment: SegmentItem, at index: Int) {
    
    self.segments.remove(at: index)
    self.segments.insert(segment, at: index)
    (self.collectionView.cellForItem(at: IndexPath(item: index, section: 0)) as? SegmentCell)?.update(with: segment)
  }
  
  /// 自定义SegmentItem来自定义Segment图片及文字样式
  func update(_ segments: [SegmentItem]) {
    
    self.segments = segments
    self.flowLayout.itemSize.width = self.bounds.width / CGFloat(self.segments.count > 4 ? 4 : self.segments.count)
    self.collectionView.reloadData()
    self.page(to: 0, withSource: self)
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
    
    guard self.segments.count > 0 else { return }
    
    let indexPath = IndexPath(item: index, section: 0)
    self.collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
    self.updateIndicator(at: indexPath)
  }
  
}

// MARK: - Setup
private extension SegmentView {
  
  func setupUI() {
    
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
    
    self.pageObserver?.pageWillPage(at: self.currentIndex, withSource: self)
    return true
  }
  
  public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    
    self.collectionView.scrollToItem(at: IndexPath(item: indexPath.item, section: 0), at: .centeredHorizontally, animated: true)
    self.pageObserver?.page(to: indexPath.item, withSource: self)
    self.updateIndicator(at: indexPath)
  }
  
  public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {

    guard cell.isSelected == true else { return }
    self.updateIndicator(at: cell)
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
  
  func updateIndicator(at indexPath: IndexPath) {
    
    guard let cell = collectionView.cellForItem(at: indexPath) else { return }
    
    self.updateIndicator(at: cell)
  }
  
  func updateIndicator(at cell: UICollectionViewCell) {
    
    UIView.animate(withDuration: self.animationDuration, animations: {
      
      self.indicatorView.center.x = cell.center.x
      
    }, completion: { (_) in
      
      self.pageObserver?.pageDidPage(to: self.currentIndex, withSource: self)
    })
  }
  
}












