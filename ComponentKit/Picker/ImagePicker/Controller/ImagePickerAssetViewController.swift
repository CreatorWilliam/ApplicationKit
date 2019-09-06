//
//  ImagePickerGridViewController.swift
//  Base
//
//  Created by William Lee on 2018/4/27.
//  Copyright © 2018 William Lee. All rights reserved.
//

import Photos
import UIKit

class ImagePickerAssetViewController: UIViewController {
  
  //private let server = CollectionServer()
  private let layout = UICollectionViewFlowLayout()
  private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: self.layout)
  private let previewView = ImagePickerPreviewView()
  
  // 展示选择数量
  private let bottomView = UIView()
  private let countLabel = UILabel()
  private let completionButton = UIButton(type: .custom)
  
  // 选择图片数
  private var maxCount: Int = 0
  // 选择回调
  private var completedHandle: AssetSelectionHandle?
  
  // 所有图片
  var album: AlbumItem?
  private var fetchAllPhtos: PHFetchResult<PHAsset>!
  
  private var group: [AssetItem] = []
  private var selectedAssets: [AssetItem] = []
  
  private let imageManager = PHCachingImageManager()
  // 单个相册
  //internal var assetCollection: PHAssetCollection!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // 监测数据源
    if self.album == nil {
      
      let allPhotoOptions = PHFetchOptions()
      allPhotoOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
      let allPhotos = PHAsset.fetchAssets(with: allPhotoOptions)
      self.album = AlbumItem(allPhotos, "全部图片")
    }
    self.fetchAllPhtos = self.album?.result
    self.updateGroups()
    
    self.setupUI()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    // 更新
    self.updateCachedAssets()
  }
  
}

// MARK: - Public
extension ImagePickerAssetViewController {
  
  func setup(limited count: Int, complete handle: AssetSelectionHandle?) {
    
    self.maxCount = count
    self.completedHandle = handle
  }
  
}

// MARK: PHAsset Caching
private extension ImagePickerAssetViewController {
  
  /// 重置图片缓存
  func resetCachedAssets() {
    
    self.imageManager.stopCachingImagesForAllAssets()
  }
  
  /// 更新图片缓存设置
  func updateCachedAssets() {
    
    // 视图可访问时才更新
    guard self.isViewLoaded && self.view.window != nil else { return }
    
    // 更新图片缓存
    var indexPaths: [IndexPath] = []
    self.collectionView.visibleCells.forEach({ [weak self] (cell) in
      
      if let indexPath = self?.collectionView.indexPath(for: cell) {
        
        indexPaths.append(indexPath)
      }
    })
    guard let album = self.album else { return }
    self.imageManager.startCachingImages(for: indexPaths.map({ album.assets[$0.item].asset }), targetSize: CGSize(width: 150, height: 150), contentMode: .aspectFill, options: nil)
  }
  
}

// MARK: - UIScrollViewDelegate
extension ImagePickerAssetViewController: UIScrollViewDelegate {
  
  //  func scrollViewDidScroll(_ scrollView: UIScrollView) {
  //
  //    self.updateCachedAssets()
  //  }
  
  func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    
    self.updateCachedAssets()
  }
  
}

// MARK: - UICollectionViewDelegate
extension ImagePickerAssetViewController: UICollectionViewDelegate {

  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

    self.showLargeView(self.group[indexPath.item])
    collectionView.deselectItem(at: indexPath, animated: true)
  }

}

// MARK: - UICollectionViewDataSource
extension ImagePickerAssetViewController: UICollectionViewDataSource {

  func numberOfSections(in collectionView: UICollectionView) -> Int {

    return 1
  }

  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

    return self.group.count
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageAssetCollectionViewCell", for: indexPath)

    if let cell = cell as? ImageAssetCollectionViewCell {
      
      cell.isShowChoice = (self.maxCount > 1)
      cell.delegate = self
      cell.imageManager = self.imageManager
      if let index = self.selectedAssets.firstIndex(where: { $0.asset.localIdentifier == self.group[indexPath.item].asset.localIdentifier }) {
        
        cell.update(with: "\(index + 1)")
        
      } else {
        
        cell.update(with: nil)
      }
      cell.update(with: self.group[indexPath.item])
    }

    return cell
  }

}

// MARK: - ImageAssetCollectionViewCellDelegate
extension ImagePickerAssetViewController: ImageAssetCollectionViewCellDelegate {
  
  func select(_ asset: AssetItem) {
    
    // 单选
    if self.maxCount < 2 {
      
      self.selectedAssets.append(asset)
      self.completeSelection()
      return
    }
    
    // 多选
    defer {
      
      self.collectionView.reloadData()
    }
    guard self.selectedAssets.count < self.maxCount else {
      
      self.showAlert()
      return
    }
    self.selectedAssets.append(asset)
    self.updateCount()
  }
  
  func deselect(_ asset: AssetItem) {
    
    defer {
      
      self.collectionView.reloadData()
    }
    for (index, item) in self.selectedAssets.enumerated() {
      
      guard item.asset.localIdentifier == asset.asset.localIdentifier else { continue }
      self.selectedAssets.remove(at: index)
      self.updateCount()
      return
    }
  }
  
}

// MARK: - Setup
private extension ImagePickerAssetViewController {
  
  /// 展示
  private func setupUI() {
    
    self.navigationView.setup(title: self.album?.title)
    self.navigationView.addRight(title: "取消", target: self, action: #selector(clickCancel))
    self.navigationView.showBack()
    
    let spaceing: CGFloat = 3
    let count: CGFloat = 3
    let width = (UIScreen.main.bounds.width - (count + 1) * spaceing) / count
    
    self.layout.itemSize = CGSize(width: width, height: width)
    self.layout.minimumLineSpacing = spaceing
    self.layout.minimumInteritemSpacing = spaceing
    
    self.collectionView.delegate = self
    self.collectionView.dataSource = self
    self.collectionView.contentInset = UIEdgeInsets(top: spaceing, left: spaceing, bottom: spaceing, right: spaceing)
    self.collectionView.allowsMultipleSelection = (self.maxCount > 1)
    self.collectionView.backgroundColor = .white
    self.collectionView.register(ImageAssetCollectionViewCell.self, forCellWithReuseIdentifier: "ImageAssetCollectionViewCell")
    self.view.addSubview(self.collectionView)
    self.collectionView.layout.add { (make) in
      
      make.top().equal(self.navigationView).bottom()
      make.leading().trailing().equal(self.view)
    }
    
    self.view.addSubview(self.bottomView)
    self.bottomView.layout.add { (make) in
      
      if self.maxCount < 2 {
        
        make.leading().trailing().equal(self.view)
        make.bottom(50).equal(self.view).safeBottom()
        
      } else {
        
        make.leading().trailing().equal(self.view)
        make.bottom().equal(self.view).safeBottom()
      }
      make.top().equal(self.collectionView).bottom()
      make.height(50)
    }
    
    self.countLabel.font = UIFont.systemFont(ofSize: 14)
    self.bottomView.addSubview(self.countLabel)
    self.countLabel.layout.add { (make) in
      
      make.leading(15).centerY().equal(self.bottomView)
    }
    
    self.completionButton.setTitle("完成", for: .normal)
    self.completionButton.setTitleColor(UIColor.black, for: .normal)
    self.completionButton.layer.borderColor = UIColor.black.cgColor
    self.completionButton.layer.borderWidth = 0.5
    self.completionButton.layer.cornerRadius = 5
    self.completionButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
    self.completionButton.addTarget(self, action: #selector(clickCompletion), for: .touchUpInside)
    self.bottomView.addSubview(self.completionButton)
    self.completionButton.layout.add { (make) in
      
      make.centerY().trailing(-15).height(-20).equal(self.bottomView)
      make.width(60)
    }
    
    self.previewView.alpha = 0
    self.view.addSubview(self.previewView)
    self.previewView.layout.add { (make) in
      
      make.top().equal(self.navigationView).bottom()
      make.leading().trailing().bottom().equal(self.view)
    }
  }
  
  func updateGroups() {
    
    self.group.removeAll()
    self.album?.assets.forEach({ self.group.append($0) })
    self.collectionView.reloadData()
  }
  
}

// MARK: - Action
private extension ImagePickerAssetViewController {
  
  /// 照片选择结束
  @objc func clickCompletion(_ sender: Any) {
    
    self.completeSelection()
  }
  
  /// 取消照片选择
  @objc func clickCancel(_ sender: Any) {
    
    self.dismiss(animated: true)
  }
  
}

// MARK: - Utility
private extension ImagePickerAssetViewController {
  
  func showAlert() {
    
    let alertViewController = UIAlertController(title: "提示", message: "最多只能选择 \(self.maxCount) 张图片", preferredStyle: .alert)
    alertViewController.addAction(UIAlertAction(title: "确定", style: .default, handler: nil))
    
    DispatchQueue.main.async {
      
      self.present(alertViewController, animated: true)
    }
  }
  
  func showLargeView(_ item: AssetItem) {
    
    self.imageManager.requestImage(for: item.asset, targetSize: CGSize(width: 150, height: 150), contentMode: .aspectFill, options: nil, resultHandler: { [weak self] (image, _) in
      
      self?.previewView.update(with: image)
      UIView.animate(withDuration: 0.5, animations: {
        
        self?.previewView.alpha = 1.0
        
      }, completion: { (_) in
        
      })
    })
    
  }
  
  private func updateCount() {
    
    let count = self.selectedAssets.count
    self.countLabel.text = "已选择：\(count) 张"
  }
  
  func completeSelection() {
    
    var images: [UIImage] = []
    var assets: [PHAsset] = []
    self.selectedAssets.forEach({ (item) in
      
      assets.append(item.asset)
      self.imageManager.requestImage(for: item.asset, targetSize: UIScreen.main.bounds.size, contentMode: PHImageContentMode.default, options: nil, resultHandler: { (image, _) in
        
        if let image = image {
          
          images.append(image)
        }
      })
    })
    
    self.completedHandle?(assets, images)
    self.dismiss(animated: true)
  }
  
}








