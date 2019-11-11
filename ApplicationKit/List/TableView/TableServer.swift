//
//  TableServer.swift
//  ComponentKit
//
//  Created by William Lee on 22/01/2018.
//  Copyright © 2018 William Lee. All rights reserved.
//

import UIKit

public class TableServer: NSObject {
  
  // MARK: ******************** Public ********************
  /// TableView
  public var tableView: UITableView {
    
    didSet {
      
      tableView.delegate = self
      tableView.dataSource = self
      tableView.separatorInset = UIEdgeInsets(top: 0, left: 0.01, bottom: 0, right: 0.01)
      guard tableView.style == .plain else { return }
      tableView.tableFooterView = UIView()
    }
  }
  /// 空视图
  public var emptyContentView: UIView? {
    
    didSet {
      
      tableView.backgroundView = emptyContentView
      emptyContentView?.isHidden = true
    }
  }
  
  /// 是否可以移动
  public var canMoveRow: Bool = false
  public typealias MoveHandle = (_ sourceIndexPath: IndexPath, _ destinationIndexPath: IndexPath) -> Void
  public var moveHandle: MoveHandle?
  
  /// UIScrollViewDelegate
  public weak var scrollViewDelegate: UIScrollViewDelegate?
  
  /// 是否选中后执行反选动画
  public var isDeselectAutomatically: Bool = true

  /// 数据源
  public var groups: [TableSectionGroup] = []
  
  // MARK: ******************** Public ********************
  /// 重用的Cell组
  private var reusedCells: Set<String> = []
  /// 重用的SectionView组
  private var reusedSectionViews: Set<String> = []
  
  // 缓存的Row高度
  private var cachedRowHeights: [IndexPath: CGFloat] = [:]
  // 缓存的Header高度
  private var cachedHeaderHeights: [Int: CGFloat] = [:]
  // 缓存的Footer高度
  private var cachedFooterHeights: [Int: CGFloat] = [:]

  public init(tableStyle style: UITableView.Style = .grouped) {

    tableView = UITableView(frame: .zero, style: style)
    
    super.init()
    
    tableView.delegate = self
    tableView.dataSource = self
    tableView.separatorInset = UIEdgeInsets(top: 0, left: 0.01, bottom: 0, right: 0.01)
    guard tableView.style == .plain else { return }
    tableView.tableFooterView = UIView()
  }
  
}

// MARK: - Public
public extension TableServer {
  
  /// 使用数据源全部更新
  ///
  /// - Parameter newGroups: 所有Section的数据源
  func update(_ newGroups: [TableSectionGroup]) {
    
    groups = newGroups
    
    registerNewViews(with: newGroups)
    
    tableView.reloadData()
    
    for group in groups {
      
      guard group.items.isEmpty == false else { continue }
      emptyContentView?.isHidden = true
      return
    }
    emptyContentView?.isHidden = false
  }
 
  /// 使用数据源局部更新
  ///
  /// - Parameters:
  ///   - groups: Sections的数据源
  ///   - sections: Sections的索引
  ///   - animation: 动画
  func update(_ groups: [TableSectionGroup], at sections: IndexSet, with animation: UITableView.RowAnimation = .none) {
    
    sections.forEach({ self.groups[$0] = groups[$0] })

    registerNewViews(with: groups)
    
    tableView.reloadSections(sections, with: animation)
    
    for group in groups {
      
      guard group.items.isEmpty == false else { continue }
      emptyContentView?.isHidden = true
      return
    }
    emptyContentView?.isHidden = false
  }
  
  /// 下拉操作
  ///
  /// - Parameter action: 触发下拉动作时执行
  func addPullDown(action: @escaping () -> Void) {
    
    tableView.es.addPullToRefresh(handler: {
      
      action()
    })
  }
  
  /// 上拉操作
  ///
  /// - Parameter action: 触发下拉动作时执行
  func addPullUp(action: @escaping () -> Void) {
    
    tableView.es.addInfiniteScrolling {
      
      action()
    }
  }
  
}

// MARK: - UITableViewDelegate
extension TableServer: UITableViewDelegate {
  
  // MARK: ---------- Row
  
  // Will Highlight
  public func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
    
    return groups[indexPath.section].items[indexPath.row].selectedHandle != nil
  }
  
  // Will Select
  public func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
    
    if groups[indexPath.section].items[indexPath.row].selectedHandle == nil { return nil }
    if tableView.cellForRow(at: indexPath)?.isSelected == true { return nil }
    return indexPath
  }
  
  // Did Select
  public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
    if isDeselectAutomatically == true {
      
      tableView.deselectRow(at: indexPath, animated: true)
    }
    groups[indexPath.section].items[indexPath.row].selectedHandle?()
  }
  
  // Will Deselect
  public func tableView(_ tableView: UITableView, willDeselectRowAt indexPath: IndexPath) -> IndexPath? {
    
    //if groups[indexPath.section].items[indexPath.row].deselectedHandle == nil { return nil }
    return indexPath
  }
  
  // Did Deselect
  public func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
    
    groups[indexPath.section].items[indexPath.row].deselectedHandle?()
  }
  
  /// Can Move
  public func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
    
    return canMoveRow
  }
  
  public func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
    
    moveHandle?(sourceIndexPath, destinationIndexPath)
  }
  
  // Will Display Cell
  public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    
    cell.preservesSuperviewLayoutMargins = false
    cell.separatorInset = groups[indexPath.section].items[indexPath.row].seperatorInsets ?? tableView.separatorInset
  }
  
  // Did Display Cell
  public func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    
    cachedRowHeights[indexPath] = cell.bounds.height
  }
  
  // Estimated Height Cell
  public func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
    
    var estimatedHeight: CGFloat = UITableView.automaticDimension
    
    if let height = cachedRowHeights[indexPath], height > 1 {
      
      estimatedHeight = height
      
    } else if groups[indexPath.section].items[indexPath.row].height > 1 {
      
      estimatedHeight = groups[indexPath.section].items[indexPath.row].height
      
    } else {
      
      estimatedHeight = tableView.estimatedRowHeight
    }
    
    return estimatedHeight
  }
  
  // Height Cell
  public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    
    var height = UITableView.automaticDimension
    
    if tableView.rowHeight > 0 {
      
      height = tableView.rowHeight
      
    } else {
      
      height = groups[indexPath.section].items[indexPath.row].height
    }
    return height
  }
  
  // Editable Cell
  public func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    
    return groups[indexPath.section].items[indexPath.row].deleteHandle != nil
  }
  
  // EditStyle Cell
  public func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
    
    if groups[indexPath.section].items[indexPath.row].deleteHandle != nil { return .delete }
    
    return .none
  }
  
  // EditAction Cell
  public func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    
    if editingStyle == .delete {
      
      groups[indexPath.section].items[indexPath.row].deleteHandle?()
      groups[indexPath.section].items.remove(at: indexPath.row)
      tableView.deleteRows(at: [indexPath], with: .fade)
      cachedRowHeights[indexPath] = nil
    }
  }
  
  // MARK: ---------- Header
  
  // Estimated Height Of Header
  public func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
    
    var estimatedHeight = UITableView.automaticDimension
    if let height = cachedHeaderHeights[section], height > 1 {
      
      estimatedHeight = height
      
    } else if groups[section].header.height > 1 {
      
      estimatedHeight = groups[section].header.height
      
    } else {
      
      estimatedHeight = tableView.estimatedSectionHeaderHeight
    }
    // 必须保证返回值不在(0, 1]区间内
    return estimatedHeight
  }
  
  // Height Of Header
  public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    
    if tableView.sectionHeaderHeight > 0 { return tableView.sectionHeaderHeight }
    return groups[section].header.height
  }
  
  // View Of Section Header
  public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    
    let item = groups[section].header
    
    var sectionView: UIView? = item.view
    
    if let reuseID = item.reuseItem?.id {
      
      sectionView = tableView.dequeueReusableHeaderFooterView(withIdentifier: reuseID)
    }
    
    if let sectionView = sectionView as? TableSectionItemUpdatable {
      
      sectionView.update(with: item)
    }
    
    return sectionView
  }
  
  // Did Display Header
  public func tableView(_ tableView: UITableView, didEndDisplayingHeaderView view: UIView, forSection section: Int) {
    
    cachedHeaderHeights[section] = view.bounds.height
  }
  
  // MARK: ---------- Footer
  
  // Estimated Height Of Footer
    public func tableView(_ tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat {
      
      var estimatedHeight = UITableView.automaticDimension
      if let height = cachedFooterHeights[section], height > 1 {
        
        estimatedHeight = height
        
      } else if groups[section].footer.height > 1 {
        
        estimatedHeight = groups[section].footer.height
        
      } else {
        
        estimatedHeight = tableView.estimatedSectionFooterHeight
      }
      // 必须保证返回值不在(0, 1]区间内
      return estimatedHeight
    }
  
  // Height Of Footer
  public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    
    if tableView.sectionFooterHeight > 0 {
      
      return tableView.sectionFooterHeight
    }
    return groups[section].footer.height
  }
  
  // View Of Section Footer
  public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
    
    let item = groups[section].footer
    
    var sectionView: UIView? = item.view
    
    if let reuseID = item.reuseItem?.id {
      
      sectionView = tableView.dequeueReusableHeaderFooterView(withIdentifier: reuseID)
    }
    
    if let sectionView = sectionView as? TableSectionItemUpdatable {
      
      sectionView.update(with: item)
    }
    
    return sectionView
  }
  
  // Did Display Footer
  public func tableView(_ tableView: UITableView, didEndDisplayingFooterView view: UIView, forSection section: Int) {
    
    cachedFooterHeights[section] = view.bounds.height
  }
  
}

// MARK: - UITableViewDelegate
extension TableServer: UITableViewDataSource {
  
  public func numberOfSections(in tableView: UITableView) -> Int {
    
    return groups.count
  }
  
  public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
    return groups[section].items.count
  }
  
  public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    let item = groups[indexPath.section].items[indexPath.row]
    
    // 若设置了静态Cell，则使用静态Cell
    var cell: UITableViewCell
    if let staticCell = item.staticCell { cell = staticCell }
    // 若设置了动态Cell，则使用动态Cell
    else if let reuseItem = item.reuseItem { cell = tableView.dequeueReusableCell(withIdentifier: reuseItem.id, for: indexPath) }
    // 默认的Cell
    else { cell = UITableViewCell(style: .default, reuseIdentifier: nil) }
    
    cell.accessoryType = item.accessoryType
    if let cell = cell as? TableCellItemUpdatable { cell.update(with: item) }
    
    return cell
  }
  
}

// MARK: - UIScrollViewDelegate
extension TableServer: UIScrollViewDelegate {
 
  public func scrollViewDidScroll(_ scrollView: UIScrollView) {
    
    scrollViewDelegate?.scrollViewDidScroll?(scrollView)
  }
  
  public func scrollViewDidZoom(_ scrollView: UIScrollView) {
    
    scrollViewDelegate?.scrollViewDidZoom?(scrollView)
  }
  
  public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
    
    scrollViewDelegate?.scrollViewWillBeginDragging?(scrollView)
  }
  
  public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
    
    scrollViewDelegate?.scrollViewWillEndDragging?(scrollView, withVelocity: velocity, targetContentOffset: targetContentOffset)
  }
  
  public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
    
    scrollViewDelegate?.scrollViewDidEndDragging?(scrollView, willDecelerate: decelerate)
  }
  
  public func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
    
    scrollViewDelegate?.scrollViewWillBeginDecelerating?(scrollView)
  }
  
  public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    
    scrollViewDelegate?.scrollViewDidEndDecelerating?(scrollView)
  }
  
  public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
    
    scrollViewDelegate?.scrollViewDidEndScrollingAnimation?(scrollView)
  }
  
  public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
    
    return scrollViewDelegate?.viewForZooming?(in: scrollView)
  }
  
  public func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
    
    scrollViewDelegate?.scrollViewWillBeginZooming?(scrollView, with: view)
  }
  
  public func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
    
    scrollViewDelegate?.scrollViewDidEndZooming?(scrollView, with: view, atScale: scale)
  }
  
  public func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
    
    return scrollViewDelegate?.scrollViewShouldScrollToTop?(scrollView) ?? true
  }
  
  public func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {
    
    scrollViewDelegate?.scrollViewDidScrollToTop?(scrollView)
  }
  
  
  /* Also see -[UIScrollView adjustedContentInsetDidChange]
   */
  @available(iOS 11.0, *)
  public func scrollViewDidChangeAdjustedContentInset(_ scrollView: UIScrollView) {
    
    scrollViewDelegate?.scrollViewDidChangeAdjustedContentInset?(scrollView)
  }
  
  
}

// MARK: - Utility
private extension TableServer {
  
  func registerNewViews(with groups: [TableSectionGroup]) {
    
    var newSectionViews: [ReuseItem] = []
    var newCells: [ReuseItem] = []
    groups.forEach({ (group) in
      
      if let reuseItem = group.header.reuseItem, !reusedSectionViews.contains(reuseItem.id) {
        
        newSectionViews.append(reuseItem)
        reusedSectionViews.insert(reuseItem.id)
      }
      
      if let reuseItem = group.footer.reuseItem, !reusedSectionViews.contains(reuseItem.id) {
        
        newSectionViews.append(reuseItem)
        reusedSectionViews.insert(reuseItem.id)
      }
      
      group.items.forEach({ (cell) in
        
        if let reuseItem = cell.reuseItem, !reusedCells.contains(reuseItem.id) {
          
          newCells.append(reuseItem)
          reusedCells.insert(reuseItem.id)
        }
        
      })
      
    })
    
    if newSectionViews.count > 0 {
      
      tableView.register(sectionViews: newSectionViews)
    }
    
    if newCells.count > 0 {
      
      tableView.register(cells: newCells)
    }
    
  }
  
}
