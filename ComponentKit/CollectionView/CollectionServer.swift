//
//  CollectionServer.swift
//  ComponentKit
//
//  Created by William Lee on 27/01/2018.
//  Copyright © 2018 William Lee. All rights reserved.
//

import UIKit

public class CollectionServer: NSObject {
  
  /// 数据源
  private var groups: [CollectionSectionGroup] = []
  
  /// 空视图
  private var emptyContentView: UIView?
  
  /// 重用的Cell
  private var reusedCells: Set<String> = []
  /// 集合视图
  private weak var collectionView: UICollectionView?
  /// 滚动代理，分发集合视图的滚动视图事件
  private weak var scrollViewDelegate: UIScrollViewDelegate?
}

// MARK: - Public
public extension CollectionServer {
  
  /// 配置集合服务
  ///
  /// - Parameters:
  ///   - collectionView: 接受服务的集合视图
  ///   - emptyContentView: 无内容时显示的空内容视图
  ///   - scrollViewDelegate: 用于获取集合视图的滚动事件
  func setup(_ collectionView: UICollectionView,
             emptyContentView: UIView? = nil,
             scrollViewDelegate: UIScrollViewDelegate? = nil) {
    
    self.scrollViewDelegate = scrollViewDelegate
    
    self.collectionView = collectionView
    self.collectionView?.delegate = self
    self.collectionView?.dataSource = self
    
    self.emptyContentView = emptyContentView
    self.emptyContentView?.isHidden = true
    self.collectionView?.backgroundView = emptyContentView
  }
 
  func update(_ groups: [CollectionSectionGroup]) {
    
    self.groups = groups
    
    //var newSectionViews: [ReuseItem] = []
    var newCells: [ReuseItem] = []
    self.groups.forEach({ (group) in
      /*
      if let reuseItem = group.header.reuseItem, !self.reusedSectionViews.contains(reuseItem.id) {
        
        newSectionViews.append(reuseItem)
        self.reusedSectionViews.insert(reuseItem.id)
      }
      
      if let reuseItem = group.footer.reuseItem, !self.reusedSectionViews.contains(reuseItem.id) {
        
        newSectionViews.append(reuseItem)
        self.reusedSectionViews.insert(reuseItem.id)
      }
      */
      group.items.forEach({ (cell) in
        
        if !self.reusedCells.contains(cell.reuse.id) {
          
          newCells.append(cell.reuse)
          self.reusedCells.insert(cell.reuse.id)
        }
        
      })
      
    })
    
    /*
    if newSectionViews.count > 0 {

      self.collectionView?.register(sectionViews: newSectionViews)
    }
    */
    if newCells.count > 0 {
      
      self.collectionView?.register(cells: newCells)
    }
    
    self.collectionView?.reloadData()
    self.emptyContentView?.isHidden = (self.groups.reduce(0, { $0 + $1.items.count }) > 0)
  }
  
}

// MARK: - UICollectionViewDelegate
extension CollectionServer: UICollectionViewDelegate {
  
  // MARK: ---------- Row
  
  // Should Select
  public func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
    
    if self.groups[indexPath.section].items[indexPath.item].selectedHandle != nil {
      
      // 默认为true
      return self.groups[indexPath.section].items[indexPath.item].shouldSelectedHandle?() ?? true
    }
    
    return false
  }
  
  // Did Select
  public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    
    self.groups[indexPath.section].items[indexPath.item].selectedHandle?()
  }
  
  // Should Deselect
  public func collectionView(_ collectionView: UICollectionView, shouldDeselectItemAt indexPath: IndexPath) -> Bool {
    
    return self.groups[indexPath.section].items[indexPath.item].deselectedHandle != nil
  }
  
  // Did Deselect
  public func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
    
    self.groups[indexPath.section].items[indexPath.item].deselectedHandle?()
  }
  
}

// MARK: - UICollectionViewDataSource
extension CollectionServer: UICollectionViewDataSource {
  
  public func numberOfSections(in collectionView: UICollectionView) -> Int {
    
    return self.groups.count
  }
  
  public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    
    return self.groups[section].items.count
  }
  
  public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    
    let item = self.groups[indexPath.section].items[indexPath.item]
    
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: item.reuse.id, for: indexPath)
    
    if let cell = cell as? CollectionCellItemUpdatable {
      
      cell.update(with: item)
    }
    
    return cell
  }
  
  
}

// MARK: - UIScrollViewDelegate
extension CollectionServer: UIScrollViewDelegate {
  
  public func scrollViewDidScroll(_ scrollView: UIScrollView) {
    
    self.scrollViewDelegate?.scrollViewDidScroll?(scrollView)
  }
  
  public func scrollViewDidZoom(_ scrollView: UIScrollView) {
    
    self.scrollViewDelegate?.scrollViewDidZoom?(scrollView)
  }
  
  public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
    
    self.scrollViewDelegate?.scrollViewWillBeginDragging?(scrollView)
  }
  
  public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
    
    self.scrollViewDelegate?.scrollViewWillEndDragging?(scrollView, withVelocity: velocity, targetContentOffset: targetContentOffset)
  }
  
  public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
    
    self.scrollViewDelegate?.scrollViewDidEndDragging?(scrollView, willDecelerate: decelerate)
  }
  
  public func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
    
    self.scrollViewDelegate?.scrollViewWillBeginDecelerating?(scrollView)
  }
  
  public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    
    self.scrollViewDelegate?.scrollViewDidEndDecelerating?(scrollView)
  }
  
  public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
    
    self.scrollViewDelegate?.scrollViewDidEndScrollingAnimation?(scrollView)
  }
  
  public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
    
    return self.scrollViewDelegate?.viewForZooming?(in: scrollView)
  }
  
  public func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
    
    self.scrollViewDelegate?.scrollViewWillBeginZooming?(scrollView, with: view)
  }
  
  public func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
    
    self.scrollViewDelegate?.scrollViewDidEndZooming?(scrollView, with: view, atScale: scale)
  }
  
  public func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
    
    return self.scrollViewDelegate?.scrollViewShouldScrollToTop?(scrollView) ?? true
  }
  
  public func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {
    
    self.scrollViewDelegate?.scrollViewDidScrollToTop?(scrollView)
  }
  
  
  /* Also see -[UIScrollView adjustedContentInsetDidChange]
   */
  @available(iOS 11.0, *)
  public func scrollViewDidChangeAdjustedContentInset(_ scrollView: UIScrollView) {
    
    self.scrollViewDelegate?.scrollViewDidChangeAdjustedContentInset?(scrollView)
  }
  
}









