//
//  ImageBrowerView.swift
//  ComponentKit
//
//  Created by William Lee on 18/12/17.
//  Copyright © 2017年 William Lee. All rights reserved.
//

import ApplicationKit
import UIKit

class ImageBrowerView: UIView {
  
  private let cellID = "Cell"
  private let pageControl = UIPageControl()
  private let flowLayout = UICollectionViewFlowLayout()
  private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: self.flowLayout)
  
  private var images: [Any] = []
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    self.setupUI()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

}

// MARK: - Public
extension ImageBrowerView {
  
  func update(images: [Any]) {
    
    self.images = images
    self.pageControl.numberOfPages = self.images.count
    self.pageControl.currentPage = 0
  }
  
  func update(index: Int) {

    DispatchQueue.main.async {
      
      self.collectionView.scrollToItem(at: IndexPath(item: index, section: 0), at: .left, animated: false)
    }
  }
  
}

// MARK: - UIScrollViewDelegate
extension ImageBrowerView: UIScrollViewDelegate {
  
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    
    self.pageControl.currentPage = Int(scrollView.contentOffset.x / UIScreen.main.bounds.width)
  }
  
}

// MARK: - UICollectionViewDelegate
extension ImageBrowerView: UICollectionViewDelegate {
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    
    Presenter.currentPresentedController?.dismiss(animated: false)
  }
  
  func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
   
    (cell as? ImageBrowerCollectionViewCell)?.resetSize()
  }
}

// MARK: - UICollectionViewDataSource
extension ImageBrowerView: UICollectionViewDataSource {
  
  func numberOfSections(in collectionView: UICollectionView) -> Int {
    
    return 1
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    
    return self.images.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: self.cellID , for: indexPath)
    
    (cell as? ImageBrowerCollectionViewCell)?.update(with: self.images[indexPath.row])
    
    return cell
  }
  
}

// MARK: - Setup
private extension ImageBrowerView {
  
  func setupUI() {
    
    self.backgroundColor = UIColor.black
    
    self.flowLayout.scrollDirection = .horizontal
    self.flowLayout.itemSize = UIScreen.main.bounds.size
    self.flowLayout.minimumLineSpacing = 0
    self.flowLayout.minimumInteritemSpacing = 0
    
    self.collectionView.delegate = self
    self.collectionView.dataSource = self
    self.collectionView.backgroundColor = UIColor.black
    self.collectionView.isPagingEnabled = true
    self.collectionView.showsVerticalScrollIndicator = false
    self.collectionView.showsHorizontalScrollIndicator = false
    self.collectionView.register(ImageBrowerCollectionViewCell.self, forCellWithReuseIdentifier: self.cellID)
    self.addSubview(self.collectionView)
    self.collectionView.layout.add{(make) in
      make.top().leading().trailing().bottom().equal(self)
    }
    
    self.pageControl.isUserInteractionEnabled = false
    self.pageControl.hidesForSinglePage = true
    self.pageControl.currentPageIndicatorTintColor = UIColor.blue
    self.pageControl.pageIndicatorTintColor = UIColor.white
    self.addSubview(self.pageControl)
    self.pageControl.layout.add { (make) in
      make.leading().trailing().equal(self)
      make.bottom().equal(self).safeBottom()
      make.height(30)
    }
  }
  
}
