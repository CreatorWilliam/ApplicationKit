//
//  Listable.swift
//  ApplicationKit
//
//  Created by William Lee on 2018/5/11.
//  Copyright © 2018 William Lee. All rights reserved.
//

import ComponentKit

/// 列表数据模型协议
protocol DataModelListable {
  
  /// 页码
  var pageNo: Int { set get }
  /// 是否有下一页
  var hasNextPage: Bool { set get }
  /// 列表数据
  var list: Array<Any> { set get }
  
}

/// 列表视图控制器协议
protocol ViewControllerListable: class {
  
  /// 列表控制器，列表视图所在的视图控制器，用于显示一些HUD
  var listController: UIViewController { get }
  /// 列表视图，用于操作下拉刷新，上拉加载
  var listView: UITableView { get }
  /// 数据源
  var listDataModel: DataModelListable { get }
  
  // MARK: 👉默认实现
  /// 初始化，用于配置列表视图默认的下拉刷新，上拉加载
  func setupListView(canRefresh: Bool, canLoadMore: Bool, hasLoadingView: Bool)
  /// 内部自动调用获取数据的方法：loadData，使用默认的视图样式处理
  func list(isMore: Bool, hasLoadingView: Bool)
  
  // MARK: 👉需自行实现
  /// 实际请求获取数据，需要自行实现，必须执行compketion回调
  func loadData(_ isMore: Bool, completion handle: @escaping () -> Void)

}

// MARK: - 默认实现
extension ViewControllerListable {
  
  /// 默认的初始化
  func setupListView(canRefresh: Bool, canLoadMore: Bool, hasLoadingView: Bool) {
    
    if canRefresh == true {
      
      self.listView.es.addPullToRefresh { [weak self] in
        
        self?.list(isMore: false, hasLoadingView: hasLoadingView)
      }
    }
    
    if canLoadMore == true {
      
      self.listView.es.addPullToRefresh { [weak self] in
        
        self?.list(isMore: true, hasLoadingView: hasLoadingView)
      }
    }
  }
  
  func list(isMore: Bool, hasLoadingView: Bool) {
    
    if isMore == false {
      
      if hasLoadingView == true {
        
        // Show Loading
        self.listController.hud.showLoading()
      }
      
    } else if self.listDataModel.hasNextPage == false {
      
      self.listView.es.noticeNoMoreData()
      return
      
    } else {
      
      // Nothing
    }
    
    self.loadData(isMore, completion: {
      
      if isMore == false, hasLoadingView == true {
        
        self.listController.hud.hideLoading()
        self.listView.es.stopPullToRefresh()
        
      } else if isMore == false, hasLoadingView == false {
        
        self.listView.es.stopPullToRefresh()
        
      } else if isMore == true, self.listDataModel.hasNextPage == true {
        
        self.listView.es.stopLoadingMore()
        
      } else if isMore == true, self.listDataModel.hasNextPage == false {
        
        self.listView.es.noticeNoMoreData()
        
      } else {
        
        // Nothing
      }
      
    })
    
  }
  
}










