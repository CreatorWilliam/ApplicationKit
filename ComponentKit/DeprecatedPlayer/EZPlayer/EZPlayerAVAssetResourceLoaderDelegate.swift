//
//  EZPlayerAVAssetResourceLoaderDelegate.swift
//  EZPlayer
//
//  Created by yangjun zhu on 2017/3/6.
//  Copyright © 2017年 yangjun zhu. All rights reserved.
//

import AVFoundation

class EZPlayerAVAssetResourceLoaderDelegate: NSObject {
  
  var customScheme: String {
    return ""
  }
  
  unowned let asset: AVURLAsset
  
  let delegateQueue: DispatchQueue?
  
  init(asset: AVURLAsset,delegateQueue: DispatchQueue? = nil) {
    
    self.asset = asset
    self.delegateQueue = delegateQueue
    super.init()
    self.asset.resourceLoader.setDelegate(self, queue: self.delegateQueue)
    
  }
  
}


extension EZPlayerAVAssetResourceLoaderDelegate: AVAssetResourceLoaderDelegate{
  
}
