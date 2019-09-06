//
//  ImageBrowerCollectionViewCell.swift
//  ComponentKit
//
//  Created by William Lee on 18/12/17.
//  Copyright © 2017年 William Lee. All rights reserved.
//

import ApplicationKit
import ImageKit
import Photos
import UIKit

class ImageBrowerCollectionViewCell: UICollectionViewCell {

  private let scrollView = UIScrollView()
  private let imageView = UIImageView()
  private var image: Any?
  private var imageEdgeInset: UIEdgeInsets = .zero
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    self.setupUI()
  }
  
  required init?(coder aDecoder: NSCoder) {
    
    fatalError("init(coder:) has not been implemented")
  }
  
}

// MARK: - Public
extension ImageBrowerCollectionViewCell {
  
  func update(with image: Any?) {
    
    self.scrollView.zoomScale = 1
    self.image = image
    
    if let image = image as? UIImage {
      
      self.imageView.image = image
      self.resetSize()
      
    } else if let string = image as? String, let url = URL(string: string) {
      
      self.imageView.setImage(with: url) { (image) in
       
        self.resetSize()
      }
    
    } else {
      
      // Nothing
    }
  }
  
  func resetSize() {
    
    self.scrollView.zoomScale = 1.0
    let imageSize: CGSize = self.imageView.image?.size ?? CGSize(width: 16, height: 9)
    // 宽高比
    let scale = imageSize.height / imageSize.width
    if scale > 1 {
      
      self.imageView.frame.size.height = UIScreen.main.bounds.height - self.imageEdgeInset.top - self.imageEdgeInset.bottom
      self.imageView.frame.size.width = self.imageView.bounds.size.height / scale
      
    } else {
      
      self.imageView.frame.size.width = UIScreen.main.bounds.width - self.imageEdgeInset.left - self.imageEdgeInset.right
      self.imageView.frame.size.height = self.imageView.bounds.size.width * scale
    }
    self.scrollView.contentSize = self.imageView.bounds.size
    
    self.updateImageOrigin()
  }
  
}

// MARK: - UIScrollViewDelegate
extension ImageBrowerCollectionViewCell: UIScrollViewDelegate {
  
  //缩放视图
  func viewForZooming(in scrollView: UIScrollView) -> UIView? {
    
    return self.imageView
  }
  
  //缩放响应，设置imageView的中心位置
  func scrollViewDidZoom(_ scrollView: UIScrollView) {
    
    self.updateImageOrigin()
  }
  
}

// MARK: - Setup
private extension ImageBrowerCollectionViewCell {
  
  func setupUI() {
    
    self.contentView.backgroundColor = UIColor.black
    self.imageEdgeInset = UIEdgeInsets(top: 0, left: 2.5, bottom: 0, right: 2.5)
    
    // 单击退出
    let singleTap = UITapGestureRecognizer(target:self, action:#selector(tapSingle))
    singleTap.numberOfTapsRequired = 1
    singleTap.numberOfTouchesRequired = 1
    self.scrollView.addGestureRecognizer(singleTap)

    // 长按显示图片操作菜单
    //let longPressGR = UILongPressGestureRecognizer(target: self, action: #selector(longPress))
    //self.scrollView.addGestureRecognizer(longPressGR)
    self.scrollView.bounds = self.contentView.bounds
    self.scrollView.delegate = self
    self.scrollView.maximumZoomScale = 2
    self.scrollView.minimumZoomScale = 0.5
    self.scrollView.bounces = false
    self.scrollView.backgroundColor = self.contentView.backgroundColor
    self.scrollView.showsVerticalScrollIndicator = false
    self.scrollView.showsHorizontalScrollIndicator = false
    self.contentView.addSubview(self.scrollView)
    self.scrollView.layout.add { (make) in
      
      make.top().bottom().leading().trailing().equal(self.contentView)
    }
    
    self.imageView.backgroundColor = self.contentView.backgroundColor
    self.imageView.contentMode = .scaleAspectFit
    self.scrollView.addSubview(self.imageView)
  }
  
}

// MARK: - Action
private extension ImageBrowerCollectionViewCell {
  
  @objc func tapSingle(_ sender: UITapGestureRecognizer) {
   
    Presenter.currentPresentedController?.dismiss(animated: false)
  }
  
  @objc func longPress(_ sender: UILongPressGestureRecognizer) {
    
    if sender.state != .began { return }
    
    let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
    alertController.addAction(UIAlertAction(title: "取消", style: .cancel))
    alertController.addAction(UIAlertAction(title: "保存图片", style: .default, handler: { (_) in
      
      self.saveImage()
    }))
    Presenter.present(alertController)
  }
  
}

// MARK: - Utility
private extension ImageBrowerCollectionViewCell {
  
  func saveImage() {
    
    if PHPhotoLibrary.authorizationStatus() != .authorized {
      
      PHPhotoLibrary.requestAuthorization({ (status) in
        
      })
      return
    }
    
    //var request: PHAssetChangeRequest?
    PHPhotoLibrary.shared().performChanges({
      
      guard let source = self.image else { return }
      
      var image: UIImage
      if let image_t = source as? UIImage {
        
        image = image_t
        
      } else if let url = source as? URL {
        
        guard let data = try? Data(contentsOf: url) else { return }
        guard let image_t = UIImage(data: data) else { return }
        image = image_t
        
      } else if let stringURL = source as? String {
        
        guard let url = URL(string: stringURL) else { return }
        guard let data = try? Data(contentsOf: url) else { return }
        guard let image_t = UIImage(data: data) else { return }
        image = image_t
        
      } else {
        
        return
      }
      PHAssetChangeRequest.creationRequestForAsset(from: image)
      
    }, completionHandler: { (isSuccess, error) in
      
      guard isSuccess else { return }
      Presenter.currentPresentedController?.hud.showMessage(message: "保存成功!")
      /*
       guard let id = request?.placeholderForCreatedAsset?.localIdentifier else { return }
       let result = PHAsset.fetchAssets(withLocalIdentifiers: [id], options: nil)
       result.enumerateObjects({ (asset, index, isStop) in
       
       PHImageManager.default().requestImageData(for: asset, options: nil, resultHandler: { (imageData, dataUTI, orientation, info) in
       
       })
       })
       */
    })
  }
  
  func updateImageOrigin() {
    
    if self.imageView.frame.size.width < (self.scrollView.bounds.width - self.imageEdgeInset.left - self.imageEdgeInset.right) {

      self.imageView.frame.origin.x = self.scrollView.bounds.width / 2.0 - self.imageView.frame.width / 2.0
      
    } else {
      
      self.imageView.frame.origin.x = self.imageEdgeInset.left
    }
    
    if self.imageView.frame.size.height < (self.scrollView.bounds.height - self.imageEdgeInset.top - self.imageEdgeInset.bottom) {
      
      self.imageView.frame.origin.y = self.scrollView.bounds.height / 2.0 - self.imageView.frame.height / 2.0
      
    } else {
      
      self.imageView.frame.origin.y = self.imageEdgeInset.top
    }
  }
  
}
