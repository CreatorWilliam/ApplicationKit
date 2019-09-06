//
//  SelectionViewController.swift
//  ComponentKit
//
//  Created by William Lee on 2019/7/6.
//  Copyright © 2019 William Lee. All rights reserved.
//

import ApplicationKit
import UIKit

public protocol SelectionPathCellUpdatable: UICollectionViewCell {
  
  func update(with item: MenuItem)
  
}

public protocol SelectionCellUpdatable: UITableViewCell {
  
  func update(with item: MenuItem)
  
}

public protocol SelectionViewControllerDelegate: class {
  
  /// 是否显示下一页
  func selectionViewController(_ viewController: SelectionViewController,
                               shouldShowNextFor item: MenuItem) -> Bool
  /// 是否可以多选
  func selectionViewController(_ viewController: SelectionViewController,
                               couldMutileSelectionFor item: MenuItem) -> Bool
  /// 选中
  func selectionViewController(_ viewController: SelectionViewController,
                               shouldShowNextFor item: MenuItem,
                               ation: () -> Void)
}

public class SelectionViewController: UIViewController {
  
  var rootItem = MenuItem()
  /// 用于设置显示选项路径的UICollectionViewCell
  var pathCell = ReuseItem(UICollectionViewCell.self)
  /// 用于设置显示选项的UITableViewCell
  var selectionCell = ReuseItem(UITableViewCell.self)
  
  private(set) lazy var currentItem: MenuItem = rootItem
  
  
  private let flowLayout = UICollectionViewFlowLayout()
  private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
  private let line = UIView()
  private let server = TableServer(tableStyle: .plain)
  
  private var collectionItems: [MenuItem] {
    
    var items: [MenuItem] = []
    
    var fatherItem = currentItem.fatherItem
    
    while let currentFatherItem = fatherItem {
      
      items.insert(currentFatherItem, at: 0)
      fatherItem = currentFatherItem.fatherItem
    }
    return items
  }
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    
    setupUI()
    updateUI(animation: .none)
  }
  
  public override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    
    collectionView.frame = CGRect(x: 0, y: 0, width: server.tableView.bounds.width, height: 44)
  }
  
}

// MARK: - Public
public extension SelectionViewController {
  
}

// MARK: - Setup
private extension SelectionViewController {
  
  func setupUI() {
    
    navigationView.setup(title: title, backgroundImage: nil, backgroundColor: .white)
    navigationView.showBack()
    view.backgroundColor = UIColor.white
    
    server.tableView.backgroundColor = UIColor(0xf8f8f8)
    server.tableView.separatorColor = UIColor(0xe5e5e5)
    server.tableView.rowHeight = 44
    view.addSubview(server.tableView)
    server.tableView.layout.add { (make) in
      make.top().equal(navigationView).bottom()
      make.leading().trailing().bottom().equal(view)
    }
    
    flowLayout.scrollDirection = .horizontal
    flowLayout.estimatedItemSize = CGSize(width: 44, height: 44)
    flowLayout.minimumLineSpacing = 0
    flowLayout.minimumInteritemSpacing = 0
    
    collectionView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 44)
    collectionView.delegate = self
    collectionView.dataSource = self
    collectionView.backgroundColor = .white
    collectionView.register(cells: [pathCell])
    server.tableView.tableHeaderView = collectionView
    
    line.backgroundColor = UIColor(0xe5e5e5)
    collectionView.addSubview(line)
    line.layout.add { (make) in
      make.leading().trailing().bottom().equal(collectionView)
      make.height(0.5)
    }
    
  }
  
  func updateUI(animation: UITableView.RowAnimation) {
    
    let item = currentItem
    
    /// CollectionView
    server.tableView.tableHeaderView = (collectionItems.count > 0) ? collectionView : nil
    collectionView.reloadData()
    
    /// TableView
    let cell = selectionCell
    
    var groups: [TableSectionGroup] = []
    var group = TableSectionGroup()
    let accessoryType: UITableViewCell.AccessoryType = (item.childrenItem != nil) ? .disclosureIndicator : .none
    
    item.selectionDatas.enumerated().forEach({ (index, data) in
      
      group.items.append(TableCellItem(cell, data: data, accessoryData: nil, accessoryType: accessoryType, selected: { [weak self] in
        
        item.selectedIndex = index
        self?.showNextPage()
      }))
    })
    
    groups.append(group)
    
    switch animation {
    case .none: server.update(groups)
    default: server.update(groups, at: IndexSet([0]), with: animation)
    }
  }
  
}

// MARK: - Override
private extension SelectionViewController {
  
  func showPreviewPage() {
    
    guard let fatherItem = currentItem.fatherItem else {
      Presenter.pop()
      return
    }
    
    currentItem = fatherItem
    
    updateUI(animation: .right)
  }
  
  func showNextPage() {
    
    guard let childrenItem = currentItem.childrenItem else {
      Presenter.pop()
      return
    }
    
    currentItem = childrenItem
    
    updateUI(animation: .left)
  }
  
}

// MARK: - UICollectionViewDelegate
extension SelectionViewController: UICollectionViewDelegate {
  
  public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    
    var item = currentItem
    for _ in 0 ..< (collectionItems.count - indexPath.item - 1) {
      
      guard let fatherItem = item.fatherItem else { break }
      item = fatherItem
    }
    
    currentItem = item
    showPreviewPage()
  }
  
}

// MARK: - UICollectionViewDataSource
extension SelectionViewController: UICollectionViewDataSource {
  
  public func numberOfSections(in collectionView: UICollectionView) -> Int {
    
    return 1
  }
  
  public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    
    return collectionItems.count
  }
  
  public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: pathCell.id, for: indexPath)
    
    (cell as? SelectionPathCellUpdatable)?.update(with: collectionItems[indexPath.item])
    
    return cell
  }
  
}
