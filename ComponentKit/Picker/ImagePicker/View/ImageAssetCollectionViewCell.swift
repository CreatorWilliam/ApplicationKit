//
//  ImagePickerCollectionViewCell.swift
//  Base
//
//  Created by William Lee on 2018/4/27.
//  Copyright © 2018 William Lee. All rights reserved.
//

import ApplicationKit
import Photos
import UIKit

protocol ImageAssetCollectionViewCellDelegate: class {
  
  func select(_ asset: AssetItem)
  
  func deselect(_ asset: AssetItem)
}

class ImageAssetCollectionViewCell: UICollectionViewCell {
  
  weak var delegate: ImageAssetCollectionViewCellDelegate?
  var isShowChoice: Bool = true
  var imageManager: PHCachingImageManager?
  
  private let imageView = UIImageView()
  private let choiceButton = UIButton(type: .custom)
  
  var image: UIImage? {
    
    set { self.imageView.image = newValue }
    
    get { return self.imageView.image }
  }
  
  private var item: AssetItem?
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    self.setupView()
    self.setupLayout()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
}

// MARK: - Public
extension ImageAssetCollectionViewCell {
  
  func update(with item: AssetItem) {
    
    self.item = item
    self.imageManager?.requestImage(for: item.asset, targetSize: CGSize(width: 150, height: 150), contentMode: .aspectFill, options: nil, resultHandler: { [weak self] (image, _) in
      
      guard self?.item?.asset.localIdentifier == item.asset.localIdentifier else { return }
      self?.image = image
    })
  }
  
  func update(with title: String?) {
    
    self.choiceButton.setTitle(title, for: .normal)
  }
  
}

// MARK: - Setup
private extension ImageAssetCollectionViewCell {
  
  func setupView() {
    
    self.imageView.clipsToBounds = true
    self.imageView.contentMode = .scaleAspectFill
    self.imageView.backgroundColor = UIColor(0xeeeeee)
    self.contentView.addSubview(self.imageView)
    
    self.choiceButton.setTitleColor(UIColor.black, for: .normal)
    self.choiceButton.layer.borderColor = UIColor.gray.cgColor
    self.choiceButton.layer.borderWidth = 1
    self.choiceButton.layer.cornerRadius = 15
    self.choiceButton.layer.backgroundColor = UIColor.white.withAlphaComponent(0.7).cgColor
    self.choiceButton.titleLabel?.font = UIFont.systemFont(ofSize: 15)
    self.choiceButton.addTarget(self, action: #selector(clickChoice(_:)), for: .touchUpInside)
    self.contentView.addSubview(self.choiceButton)
  }
  
  func setupLayout() {
    
    self.imageView.layout.add { (make) in
      
      make.top().bottom().leading().trailing().equal(self.contentView)
    }
    
    self.choiceButton.layout.add { (make) in
      
      make.top(5).trailing(-5).equal(self.contentView)
      make.width(30).height(30)
    }
  }
  
}

// MARK: - Action
private extension ImageAssetCollectionViewCell {
  
  @objc func clickChoice(_ sender: UIButton) {
    
    guard let item = self.item else { return }
    if self.choiceButton.title(for: .normal)?.count ?? 0 > 0 {
      
      self.delegate?.deselect(item)
      
    } else {
      
      self.delegate?.select(item)
    }
    
  }
  
}
