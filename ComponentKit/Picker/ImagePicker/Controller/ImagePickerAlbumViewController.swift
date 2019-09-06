//
//  ImagePickerAlbumViewController.swift
//  Base
//
//  Created by William Lee on 2018/4/27.
//  Copyright © 2018 William Lee. All rights reserved.
//

import ApplicationKit
import UIKit
import Photos

typealias AssetSelectionHandle = ([PHAsset], [UIImage]) -> Void
class ImagePickerAlbumViewController: UIViewController {
  
  /// 所有图片
  private var allPhotos: AlbumItem?
  /// 智能相册
  private var smartAlbums: [AlbumItem] = []
  /// 用户自定义相册
  private var userAlbums: [AlbumItem] = []
  /// 最大选择数
  private var maxCount: Int = 0
  
  private var handle: AssetSelectionHandle?
  
  private let server = TableServer()
  
  override public func viewDidLoad() {
    super.viewDidLoad()
    
    self.setupUI()
    
    self.showDetail(with: nil, animated: false)
    self.fetchAlbumsFromSystemAlbum()
  }
  
  deinit {
    
    PHPhotoLibrary.shared().unregisterChangeObserver(self)
  }
  
}

// MARK: - Public
extension ImagePickerAlbumViewController {
  
  class func openPicker(withLimited count: Int, completion handle: @escaping AssetSelectionHandle) {
    
    let albumViewController = ImagePickerAlbumViewController()
    albumViewController.title = "相册"
    albumViewController.maxCount = count
    if albumViewController.maxCount > 9 {
      albumViewController.maxCount = 9
    }
    if albumViewController.maxCount < 1 {
      albumViewController.maxCount = 1
    }
    albumViewController.handle = handle
    let navigationController = UINavigationController(rootViewController: albumViewController)
    UIApplication.shared.keyWindow?.rootViewController?.present(navigationController, animated: true)
  }
  
}

// MARK: - Setup
private extension ImagePickerAlbumViewController {
  
  func setupUI() {
    
    self.navigationView.setup(title: self.title)
    self.navigationView.addRight(title: "取消", target: self, action: #selector(dismissAction))
    
    self.server.tableView.rowHeight = 80
    self.view.addSubview(self.server.tableView)
    self.server.tableView.layout.add { (make) in
      make.top().equal(self.navigationView).bottom()
      make.leading().trailing().bottom().equal(self.view)
    }
  }
  
  func updateGroups() {
    
    let reuseCell = ReuseItem(ImageAlbumTableViewCell.self, "ImageAlbumTableViewCell")
    var groups: [TableSectionGroup] = []
    
    var allPhotosGroup = TableSectionGroup(header: TableSectionItem(height: 5), footer: TableSectionItem(height: 5))
    allPhotosGroup.items.append(TableCellItem(reuseCell, data: self.allPhotos, accessoryType: .disclosureIndicator, selected: { [weak self] in
      
      self?.showDetail(with: self?.allPhotos, animated: true)
    }))
    groups.append(allPhotosGroup)
    
    var smartGroup = TableSectionGroup(header: TableSectionItem(height: 5), footer: TableSectionItem(height: 5))
    self.smartAlbums.forEach({ [weak self] (album) in
      
      smartGroup.items.append(TableCellItem(reuseCell, data: album, accessoryType: .disclosureIndicator, selected: {
        
        self?.showDetail(with: album, animated: true)
      }))
    })
    groups.append(smartGroup)
    
    var userGroup = TableSectionGroup(header: TableSectionItem(height: 5), footer: TableSectionItem(height: 5))
    self.userAlbums.forEach({ [weak self] (album) in
      
      userGroup.items.append(TableCellItem(reuseCell, data: album, accessoryType: .disclosureIndicator, selected: {
        
        self?.showDetail(with: album, animated: true)
      }))
    })
    groups.append(userGroup)
    
    self.server.update(groups)
  }
  
}

// MARK: - 👉PHPhotoLibraryChangeObserver
extension ImagePickerAlbumViewController: PHPhotoLibraryChangeObserver {
  
  /// 系统相册改变
  public func photoLibraryDidChange(_ changeInstance: PHChange) {
    
    DispatchQueue.main.sync {
      
//      if let changeDetails = changeInstance.changeDetails(for: self.allPhotos) {
//
//        self.allPhotos = changeDetails.fetchResultAfterChanges
//      }
//
//      if let changeDetail = changeInstance.changeDetails(for: self.smartAlbums) {
//
//        self.smartAlbums = changeDetail.fetchResultAfterChanges
//        self.tableView.reloadSections(IndexSet(integer: AlbumSession.albumSmartAlbums.rawValue), with: .automatic)
//      }
//
//      if let changeDetail = changeInstance.changeDetails(for: userCollections) {
//
//        self.userCollections = changeDetail.fetchResultAfterChanges
//        self.tableView.reloadSections(IndexSet(integer: AlbumSession.albumUserCollection.rawValue), with: .automatic)
//      }
    }
  }
}

// MARK: - Action
private extension ImagePickerAlbumViewController {
  
  @objc func dismissAction(_ sender: Any) {
    
    self.dismiss(animated: true)
  }
  
}

// MARK: - Utility
private extension ImagePickerAlbumViewController {
  
  /// 获取所有系统相册概览信息
  func fetchAlbumsFromSystemAlbum() {
    
    // 所有图片，时间降序获取所有图片
    let allPhotoOptions = PHFetchOptions()
    allPhotoOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
    let allPhotos = PHAsset.fetchAssets(with: allPhotoOptions)
    self.allPhotos = AlbumItem(allPhotos, "全部图片")
    
    // 智能相册
    let smartAlbums = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .albumRegular, options: nil)
    for index in 0 ..< smartAlbums.count {
      
      let collection = smartAlbums.object(at: index)
      let assets = PHAsset.fetchAssets(in: collection, options: nil)
      let item = AlbumItem(assets, collection.localizedTitle)
      guard item.count > 0 else { continue }
      self.smartAlbums.append(item)
    }

    // 用户自定义相册
    let userCollections = PHCollectionList.fetchTopLevelUserCollections(with: nil)
    for index in 0 ..< userCollections.count {

      guard let collection = userCollections.object(at: index) as? PHAssetCollection else { continue }
      let assets = PHAsset.fetchAssets(in: collection, options: nil)
      let item = AlbumItem(assets, collection.localizedTitle)
      guard item.count > 0 else { continue }
      self.userAlbums.append(item)
    }
    
    // 监测系统相册增加，即使用期间是否拍照
    PHPhotoLibrary.shared().register(self)
    
    self.updateGroups()
  }
  
  func showDetail(with album: AlbumItem?, animated: Bool) {
    
    let assetViewController = ImagePickerAssetViewController()
    assetViewController.album = album
    assetViewController.title = album?.title
    assetViewController.setup(limited: self.maxCount, complete: self.handle)
    self.navigationController?.pushViewController(assetViewController, animated: animated)
  }
  
}














