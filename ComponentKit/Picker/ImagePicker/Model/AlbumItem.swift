//
//  AlbumItem.swift
//  ComponentKit
//
//  Created by William Lee on 2018/5/3.
//  Copyright © 2018 William Lee. All rights reserved.
//

import Photos

struct AlbumItem {
 
  let assets: [AssetItem]
  let result: PHFetchResult<PHAsset>
  let title: String
  let count: Int
  
  init(_ assets: PHFetchResult<PHAsset>, _ title: String?) {
    
    self.result = assets
    var items: [AssetItem] = []
    for index in 0 ..< assets.count {
      
      items.append(AssetItem(assets.object(at: index)))
    }
    self.assets = items
    self.title = title ?? ""
    self.count = self.assets.count
  }
  
}
