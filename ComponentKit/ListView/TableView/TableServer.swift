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
  public let tableView: UITableView
  /// 空视图
  public var emptyContentView: UIView? {
    
    didSet {
      
      self.tableView.backgroundView = self.emptyContentView
      self.emptyContentView?.isHidden = true
    }
  }
  
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

    self.tableView = UITableView(frame: .zero, style: style)
    super.init()
    
    self.tableView.delegate = self
    self.tableView.dataSource = self
  }
  
}

// MARK: - Public
public extension TableServer {
  
  /// 使用数据源全部更新
  ///
  /// - Parameter groups: 所有Section的数据源
  func update(_ groups: [TableSectionGroup]) {
    
    self.groups = groups
    
    self.registerNewViews(with: groups)
    
    self.tableView.reloadData()
    
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
    
    self.tableView.reloadSections(sections, with: animation)
    
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
  
  // Height Cell
  public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    
    if tableView.rowHeight > 0 {
      
      return tableView.rowHeight
    }
    return self.groups[indexPath.section].items[indexPath.row].height
  }
  
  // Editable Cell
  public func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    
    return self.groups[indexPath.section].items[indexPath.row].deleteHandle != nil
  }
  
  // EditStyle Cell
  public func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
    
    if self.groups[indexPath.section].items[indexPath.row].deleteHandle != nil { return .delete }
    
    return .none
  }
  
  // EditAction Cell
  public func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    
    if editingStyle == .delete {
      
      self.groups[indexPath.section].items[indexPath.row].deleteHandle?()
      self.groups[indexPath.section].items.remove(at: indexPath.row)
      tableView.deleteRows(at: [indexPath], with: .fade)
      self.cachedRowHeights[indexPath] = nil
    }
  }
  
  // MARK: ---------- Header
  
  // Estimated Height Of Header
    public func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
      
      // 必须保证返回值大于0
      return self.cachedHeaderHeights[section] ?? 44//UITableView.automaticDimension
    }
  
  // Height Of Header
  public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    
    if tableView.sectionHeaderHeight > 0 {
      
      return tableView.sectionHeaderHeight
    }
    return self.groups[section].header.height
  }
  
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
  
  // Did Display Header
  public func tableView(_ tableView: UITableView, didEndDisplayingHeaderView view: UIView, forSection section: Int) {
    
    self.cachedHeaderHeights[section] = view.bounds.height
  }
  
  // MARK: ---------- Footer
  
  // Estimated Height Of Footer
    public func tableView(_ tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat {
      
      // 必须保证返回值大于0
      return self.cachedFooterHeights[section] ?? 44//UITableView.automaticDimension
    }
  
  // Height Of Footer
  public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    
    if tableView.sectionFooterHeight > 0 {
      
      return tableView.sectionFooterHeight
    }
    return self.groups[section].footer.height
  }
  
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
  
  // Did Display Footer
  public func tableView(_ tableView: UITableView, didEndDisplayingFooterView view: UIView, forSection section: Int) {
    
    self.cachedFooterHeights[section] = view.bounds.height
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
      
      self.tableView.register(sectionViews: newSectionViews)
    }
    
    if newCells.count > 0 {
      
      self.tableView.register(cells: newCells)
    }
    
  }
  
}








