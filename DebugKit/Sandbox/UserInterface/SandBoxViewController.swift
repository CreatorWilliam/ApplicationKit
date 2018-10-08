//
//  SandBoxViewController.swift
//  DebugKit
//
//  Created by William Lee on 2018/10/7.
//  Copyright © 2018 William Lee. All rights reserved.
//

import UIKit

extension SandBox {
  
  public class FileListController: UIViewController {
    
    var item = SandBox.home
    
    private let tableView = UITableView(frame: .zero, style: .grouped)
    
    public override func viewDidLoad() {
      super.viewDidLoad()
      
      self.tableView.delegate = self
      self.tableView.dataSource = self
      self.tableView.estimatedSectionHeaderHeight = 0
      self.tableView.estimatedSectionFooterHeight = 0
      self.tableView.estimatedRowHeight = 44
      self.tableView.sectionHeaderHeight = 0.1
      self.tableView.sectionFooterHeight = 0.1
      self.tableView.frame = self.view.bounds
      self.view.addSubview(self.tableView)
      self.tableView.register(SandBox.FileCell.self, forCellReuseIdentifier: "Cell")
      self.tableView.backgroundColor = .black
      
      print(self.item.path)
    }
    
  }
  
}


// MARK: - UITableViewDelegate
extension SandBox.FileListController: UITableViewDelegate {
  
  public func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
   
    guard editingStyle == .delete else { return }
    self.item.remove(at: indexPath.row)
    self.tableView.reloadSections(IndexSet(integer: 0), with: .left)
  }
  public func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
    
    if self.item.subfiles[indexPath.row].isDirectory { return indexPath }
    return nil
  }
  
  public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
    let viewController = SandBox.FileListController()
    viewController.item = self.item.subfiles[indexPath.row]
    self.navigationController?.pushViewController(viewController, animated: true)
    tableView.deselectRow(at: indexPath, animated: false)
  }
  
  public func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
    
    print(self.item.subfiles[indexPath.row].path)
  }
}

// MARK: - UITableViewDataSource
extension SandBox.FileListController: UITableViewDataSource {
  
  public func numberOfSections(in tableView: UITableView) -> Int {
    
    return 1
  }
  
  public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
    return self.item.subfiles.count
  }
  
  public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
    
    if let cell = cell as? SandBox.FileCell {
      
      cell.update(with: self.item.subfiles[indexPath.row])
    }
    
    return cell
  }
  
  
}
