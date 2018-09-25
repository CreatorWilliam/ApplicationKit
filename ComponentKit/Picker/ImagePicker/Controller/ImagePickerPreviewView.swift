//
//  ImagePickerPreviewView.swift
//  ComponentKit
//
//  Created by William Lee on 2018/5/12.
//  Copyright © 2018 William Lee. All rights reserved.
//

import UIKit

class ImagePickerPreviewView: UIView {
  
  private let scrollView = UIScrollView()
  private let imageView = UIImageView()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    self.setupView()
    self.setupLayout()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesBegan(touches, with: event)
    
    self.scrollView.bounces = false
  }
  
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesEnded(touches, with: event)
    
    self.scrollView.bounces = true
  }
}

// MARK: - Public
extension ImagePickerPreviewView {
  
  func update(with image: UIImage?) {
    
    self.imageView.image = image
    self.resetSize()
  }
  
}

// MARK: - UIScrollViewDelegate
extension ImagePickerPreviewView: UIScrollViewDelegate {
  
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
private extension ImagePickerPreviewView {
  
  func setupView() {
    
    self.backgroundColor = UIColor.black
    
    let singleTap = UITapGestureRecognizer(target:self, action:#selector(tapSingle(_:)))
    singleTap.numberOfTapsRequired = 1
    singleTap.numberOfTouchesRequired = 1
    self.scrollView.addGestureRecognizer(singleTap)
    
    self.scrollView.delegate = self
    self.scrollView.maximumZoomScale = 2
    self.scrollView.minimumZoomScale = 1
    //self.scrollView.bounces = false
    self.scrollView.backgroundColor = self.backgroundColor
    self.scrollView.showsVerticalScrollIndicator = false
    self.scrollView.showsHorizontalScrollIndicator = false
    self.addSubview(self.scrollView)
    
    self.imageView.backgroundColor = self.backgroundColor
    self.imageView.contentMode = .scaleAspectFit
    self.scrollView.addSubview(self.imageView)
  }
  
  func setupLayout() {
    
    self.scrollView.layout.add { (make) in
      
      make.top().bottom().leading().trailing().equal(self)
    }
    
  }
  
}

// MARK: - Action
private extension ImagePickerPreviewView {
  
  @objc func tapSingle(_ sender: UITapGestureRecognizer) {
    
    UIView.animate(withDuration: 0.5, animations: {
      
      self.alpha = 0
      
    }, completion: { (_) in
      
      self.update(with: nil)
    })
  }
  
}

// MARK: - Utility
private extension ImagePickerPreviewView {
  
  func resetSize() {
    
    self.scrollView.zoomScale = 1.0
    let imageSize: CGSize = self.imageView.image?.size ?? CGSize(width: 16, height: 9)
    let scale = imageSize.height / imageSize.width
    self.imageView.frame.size.width = self.scrollView.bounds.width
    self.imageView.frame.size.height = self.imageView.bounds.size.width * scale
    self.scrollView.contentSize = self.imageView.bounds.size
    
    self.updateImageOrigin()
  }
  
  func updateImageOrigin() {
    
    if self.imageView.frame.size.width < self.scrollView.bounds.width {
      
      self.imageView.frame.origin.x = self.scrollView.bounds.width / 2.0 - self.imageView.frame.width / 2.0
      
    } else {
      
      self.imageView.frame.origin.x = 0
    }
    
    if self.imageView.frame.size.height < self.scrollView.bounds.height {
      
      self.imageView.frame.origin.y = self.scrollView.bounds.height / 2.0 - self.imageView.frame.height / 2.0
      
    } else {
      
      self.imageView.frame.origin.y = 0
    }
  }
  
}









