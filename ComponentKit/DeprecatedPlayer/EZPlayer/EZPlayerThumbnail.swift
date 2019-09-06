//
//  EZPlayerThumbnail.swift
//  EZPlayer
//
//  Created by yangjun zhu on 2016/12/28.
//  Copyright © 2016年 yangjun zhu. All rights reserved.
//

import AVFoundation
import UIKit

struct EZPlayerThumbnail {
  
    var requestedTime: CMTime
    var image: UIImage?
    var actualTime: CMTime
    var result: AVAssetImageGenerator.Result
    var error: Error?
}
