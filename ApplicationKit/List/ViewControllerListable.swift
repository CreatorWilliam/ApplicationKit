//
//  ViewControllerListable.swift
//  ComponentKit
//
//  Created by William Lee on 2018/5/11.
//  Copyright © 2018 William Lee. All rights reserved.
//

import UIKit

/// 列表视图控制器协议
public protocol ViewControllerListable: class {
  
  //associatedtype Item
  /// 列表控制器，列表视图所在的视图控制器，用于显示一些HUD
  var listController: UIViewController { get }
  /// 列表视图，用于操作下拉刷新，上拉加载
  var listView: UIScrollView { get }
  /// 数据源
  var listDataModel: DataModelListable { get }
  //var listData: Array<Item> { get }
  
  // MARK: 👉以下有默认实现
  /// 初始化，用于配置列表视图默认的下拉刷新，上拉加载
  func setupListView(autoLoad: Bool, canRefresh: Bool, canLoadMore: Bool, hasLoadingView: Bool)
  /// 内部自动调用获取数据的方法：loadData，使用默认的视图样式处理
  func list(isNext: Bool, hasLoadingView: Bool)
  /// 准备获取列表
  func prepareList(_ isNext: Bool, _ hasLoadingView: Bool) -> Bool
  /// 完成获取列表
  func completeList(_ isNext: Bool, _ hasLoadingView: Bool)
  
  // MARK: 👉以下需自行实现
  /// 实际请求获取数据，需要自行实现，必须执行compketion回调
  func loadData(_ isNext: Bool, completion handle: @escaping () -> Void)

}

// MARK: - ViewControllerListable默认实现
public extension ViewControllerListable {
  
  /// 默认的初始化
  func setupListView(autoLoad: Bool = true, canRefresh: Bool = true, canLoadMore: Bool = false, hasLoadingView: Bool = true) {
    
    if canRefresh == true {
      
      self.listView.es.addPullToRefresh { [weak self] in
        
        self?.list(isNext: false, hasLoadingView: hasLoadingView)
      }
    }
    
    if canLoadMore == true {
      
      self.listView.es.addInfiniteScrolling { [weak self] in
        
        self?.list(isNext: true, hasLoadingView: hasLoadingView)
      }
    }
    
    if autoLoad == true {
     
      self.list(isNext: false, hasLoadingView: hasLoadingView)
    }
  }
  
  func list(isNext: Bool, hasLoadingView: Bool) {
    
    guard self.prepareList(isNext, hasLoadingView) == true else { return }
    
    self.loadData(isNext, completion: {
      
      self.completeList(isNext, hasLoadingView)
      
    })
    
  }
  
  func prepareList(_ isNext: Bool, _ hasLoadingView: Bool) -> Bool {
    
    if isNext == false {
      
      if hasLoadingView == true {
        
        // Show Loading
        self.listController.hud.showLoading()
      }
      
    } else {
      
      if self.listDataModel.hasNextPage == false {
        
        self.listView.es.noticeNoMoreData()
        return false
      }
      
    }
    
    return true
  }
  
  func completeList(_ isNext: Bool, _ hasLoadingView: Bool) {
    
    if isNext == false {
      
      if hasLoadingView == true {
        
        self.listController.hud.hideLoading()
      }
      self.listView.es.stopPullToRefresh()
      
    } else {
      
      if self.listDataModel.hasNextPage == true {
        
        self.listView.es.stopLoadingMore()
        
      } else {
        
        self.listView.es.noticeNoMoreData()
      }
    }
  }
}
