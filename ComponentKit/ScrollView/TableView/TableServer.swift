//
//  TableServer.swift
//  ComponentKit
//
//  Created by William Lee on 22/01/2018.
//  Copyright © 2018 William Lee. All rights reserved.
//

import UIKit

public class TableServer: NSObject {
  
  /// 数据源
  public var groups: [TableSectionGroup] = []
  
  /// 空视图
  private var emptyContentView: UIView?
  
  /// 重用的Cell组
  private var reusedCells: Set<String> = []
  /// 重用的SectionView组
  private var reusedSectionViews: Set<String> = []
  
  /// 默认的重用Cell
  private lazy var defaultCell = ReuseItem(UITableViewCell.self, "Cell")
  
  /// TableView
  private weak var tableView: UITableView?
  
  /// UIScrollViewDelegate
  private weak var scrollViewDelegate: UIScrollViewDelegate?
  
  /// 是否选中后执行反选动画
  private var isDeselectAutomatically: Bool = true
  
  /// 是否有内容状态视图
  private var hasContentStateView: Bool = false
  
  // MARK: 优化性能相关属性（TODO）
  // 缓存的Row高度
  private var cachedRowHeights: [IndexPath: CGFloat] = [:]
  // 缓存的Header高度
  private var cachedHeaderHeights: [IndexPath: CGFloat] = [:]
  // 缓存的Footer高度
  private var cachedFooterHeights: [IndexPath: CGFloat] = [:]
}

// MARK: - Public
public extension TableServer {
  
  /// 配置列表服务
  ///
  /// - Parameters:
  ///   - tableView: 接受服务的列表视图
  ///   - emptyContentView: 无内容时显示的空内容视图
  ///   - scrollViewDelegate: 用于获取列表视图的滚动事件
  ///   - isDeselectAutomatically: 是否自动反选，默认true
  func setup(_ tableView: UITableView,
             emptyContentView: UIView? = nil,
             scrollViewDelegate: UIScrollViewDelegate? = nil,
             isDeselectAutomatically: Bool = true) {
    
    self.tableView = tableView
    self.scrollViewDelegate = scrollViewDelegate
    self.isDeselectAutomatically = isDeselectAutomatically
    
    tableView.delegate = self
    tableView.dataSource = self
    tableView.estimatedSectionHeaderHeight = 0
    tableView.estimatedSectionFooterHeight = 0
    
    self.emptyContentView = emptyContentView
    self.emptyContentView?.isHidden = true
    tableView.backgroundView = emptyContentView
    
    // 外部没有传入重用的Cell时候，注册一个默认的Cell
    if reusedCells.count < 1 { tableView.register(cells: [self.defaultCell]) }
    
  }
  
  /// 使用数据源全部更新
  ///
  /// - Parameter groups: 所有Section的数据源
  func update(_ groups: [TableSectionGroup]) {
    
    self.groups = groups
    
    self.registerNewViews(with: groups)
    
    self.tableView?.reloadData()
    
    self.emptyContentView?.isHidden = (self.groups.reduce(0, { $0 + $1.items.count }) > 0)
  }
 
  /// 使用数据源局部更新
  ///
  /// - Parameters:
  ///   - groups: Sections的数据源
  ///   - sections: Sections的索引
  ///   - animation: 动画
  func update(_ groups: [TableSectionGroup], at sections: IndexSet, with animation: UITableView.RowAnimation = .none) {
    
    sections.forEach({ self.groups[$0] = groups[$0] })

    self.registerNewViews(with: groups)
    
    self.tableView?.reloadSections(sections, with: animation)
    
    self.emptyContentView?.isHidden = (self.groups.reduce(0, { $0 + $1.items.count }) > 0)
  }
  
}

// MARK: - UITableViewDelegate
extension TableServer: UITableViewDelegate {
  
  // MARK: ---------- Row
  
  // Will Highlight
  public func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
    
    return self.groups[indexPath.section].items[indexPath.row].selectedHandle != nil
  }
  
  // Will Select
  public func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
    
    if self.groups[indexPath.section].items[indexPath.row].selectedHandle == nil { return nil }
    if tableView.cellForRow(at: indexPath)?.isSelected == true { return nil }
    return indexPath
  }
  
  // Did Select
  public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
    if self.isDeselectAutomatically {
      
      tableView.deselectRow(at: indexPath, animated: true)
    }
    self.groups[indexPath.section].items[indexPath.row].selectedHandle?()
  }
  
  // Will Deselect
  public func tableView(_ tableView: UITableView, willDeselectRowAt indexPath: IndexPath) -> IndexPath? {
    
    //if self.groups[indexPath.section].items[indexPath.row].deselectedHandle == nil { return nil }
    return indexPath
  }
  
  // Did Deselect
  public func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
    
    self.groups[indexPath.section].items[indexPath.row].deselectedHandle?()
  }
  
  // Will Display Cell
  public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    
    cell.preservesSuperviewLayoutMargins = false
    cell.separatorInset = self.groups[indexPath.section].items[indexPath.row].seperatorInsets
  }
  
  // Did Display Cell
  public func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    
    self.cachedRowHeights[indexPath] = cell.bounds.height
  }
  
  // Estimated Height Cell
  public func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
    
    return self.cachedRowHeights[indexPath] ?? tableView.estimatedRowHeight
  }
  
  public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    
    if tableView.rowHeight > 0 {
      
      return tableView.rowHeight
    }
    return self.groups[indexPath.section].items[indexPath.row].height
  }
  
  // MARK: ---------- Header
  
  // View Of Section Header
  public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    
    let item = self.groups[section].header
    
    var sectionView: UIView? = item.view
    
    if let reuseID = item.reuseItem?.id {
      
      sectionView = tableView.dequeueReusableHeaderFooterView(withIdentifier: reuseID)
    }
    
    if let sectionView = sectionView as? TableSectionItemUpdatable {
      
      sectionView.update(with: item)
    }
    
    return sectionView
  }
  
  // Estimated Height Of Header
  //  public func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
  //
  //    return self.groups[section].flexibleHeightOfHeader
  //  }
  
  // Height Of Header
  public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    
    return self.groups[section].header.fixedHeight
  }
  
  // MARK: ---------- Footer
  
  // View Of Section Footer
  public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
    
    let item = self.groups[section].footer
    
    var sectionView: UIView? = item.view
    
    if let reuseID = item.reuseItem?.id {
      
      sectionView = tableView.dequeueReusableHeaderFooterView(withIdentifier: reuseID)
    }
    
    if let sectionView = sectionView as? TableSectionItemUpdatable {
      
      sectionView.update(with: item)
    }
    
    return sectionView
  }
  
  // Estimated Height Of Footer
  //  public func tableView(_ tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat {
  //
  //    return self.groups[section].flexibleHeightOfFooter
  //  }
  
  // Height Of Footer
  public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    
    return self.groups[section].footer.fixedHeight
  }
  
}

// MARK: - UITableViewDelegate
extension TableServer: UITableViewDataSource {
  
  public func numberOfSections(in tableView: UITableView) -> Int {
    
    return self.groups.count
  }
  
  public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
    return self.groups[section].items.count
  }
  
  public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    let item = self.groups[indexPath.section].items[indexPath.row]
    
    let cell = item.staticCell ?? tableView.dequeueReusableCell(withIdentifier: (item.reuseItem ?? self.defaultCell).id, for: indexPath)
    cell.accessoryType = item.accessoryType
    if let cell = cell as? TableCellItemUpdatable {
      
      cell.update(with: item)
    }
    
    return cell
  }
  
}

// MARK: - UIScrollViewDelegate
extension TableServer: UIScrollViewDelegate {
 
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

// MARK: - Utility
private extension TableServer {
  
  func registerNewViews(with groups: [TableSectionGroup]) {
    
    var newSectionViews: [ReuseItem] = []
    var newCells: [ReuseItem] = []
    groups.forEach({ (group) in
      
      if let reuseItem = group.header.reuseItem, !self.reusedSectionViews.contains(reuseItem.id) {
        
        newSectionViews.append(reuseItem)
        self.reusedSectionViews.insert(reuseItem.id)
      }
      
      if let reuseItem = group.footer.reuseItem, !self.reusedSectionViews.contains(reuseItem.id) {
        
        newSectionViews.append(reuseItem)
        self.reusedSectionViews.insert(reuseItem.id)
      }
      
      group.items.forEach({ (cell) in
        
        if let reuseItem = cell.reuseItem, !self.reusedCells.contains(reuseItem.id) {
          
          newCells.append(reuseItem)
          self.reusedCells.insert(reuseItem.id)
        }
        
      })
      
    })
    
    if newSectionViews.count > 0 {
      
      self.tableView?.register(sectionViews: newSectionViews)
    }
    
    if newCells.count > 0 {
      
      self.tableView?.register(cells: newCells)
    }
    
  }
  
}







