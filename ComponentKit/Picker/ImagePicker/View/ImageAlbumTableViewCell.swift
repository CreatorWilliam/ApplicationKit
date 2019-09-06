//
//  ImageAlbumTableViewCell.swift
//  Base
//
//  Created by William Lee on 2018/4/27.
//  Copyright © 2018 William Lee. All rights reserved.
//

import ApplicationKit
import Photos
import UIKit

class ImageAlbumTableViewCell: UITableViewCell {
  
  private let thumbView = UIImageView()
  private let titleLabel = UILabel()
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    
    self.setupUI()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    self.updateUI()
  }
  
  private func updateUI() {
    
    let width = bounds.height - 16
    self.thumbView.frame = CGRect(x: 8, y: 8, width: width, height: width)
    self.titleLabel.frame = CGRect(x: self.thumbView.frame.maxX + 5, y: 4, width: 200, height: width)
  }
  
  
  private func setupUI() {
    
    self.contentView.addSubview(self.thumbView)
    self.thumbView.clipsToBounds = true
    self.thumbView.contentMode = .scaleAspectFill
    
    self.titleLabel.font = UIFont.boldSystemFont(ofSize: 17)
    self.contentView.addSubview(self.titleLabel)
  }
  
}

// MARK: - TableCellItemUpdatable
extension ImageAlbumTableViewCell: TableCellItemUpdatable {
  
  func update(with item: TableCellItem) {
    
    guard let item = item.data as? AlbumItem else { return }
    self.update(with: item)
  }
  
  func update(with album: AlbumItem) {
    
    self.titleLabel.text = "\(album.title)（\(album.count)）"
    
    let defaultSize = UIScreen.main.bounds.size
    guard let thumbAsset = album.assets.first?.asset else { return }
    PHCachingImageManager.default().requestImage(for: thumbAsset, targetSize: defaultSize, contentMode: .aspectFill, options: nil, resultHandler: { (image, _) in
      
      self.thumbView.image = image
    })
  }
  
}




























