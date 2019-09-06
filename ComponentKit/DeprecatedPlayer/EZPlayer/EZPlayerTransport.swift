//
//  EZPlayerTransport.swift
//  EZPlayer
//
//  Created by yangjun zhu on 2016/12/28.
//  Copyright © 2016年 yangjun zhu. All rights reserved.
//

import UIKit

protocol EZPlayerHorizontalPan: class {
  func player(_ player: EZPlayer ,progressWillChange value: TimeInterval)
  func player(_ player: EZPlayer ,progressChanging value: TimeInterval)
  func player(_ player: EZPlayer ,progressDidChange value: TimeInterval)
}

protocol EZPlayerGestureRecognizer: class {
  func player(_ player: EZPlayer ,singleTapGestureTapped singleTap: UITapGestureRecognizer)
  func player(_ player: EZPlayer ,doubleTapGestureTapped doubleTap: UITapGestureRecognizer)
}


protocol EZPlayerCustomAction: class {
  var player: EZPlayer? { get set }
  var autohidedControlViews: [UIView] { get set }
  
  
  func playPauseButtonPressed(_ sender: Any)
  func fullEmbeddedScreenButtonPressed(_ sender: Any)
  func audioSubtitleCCButtonPressed(_ sender: Any)
  func backButtonPressed(_ sender: Any)
}


protocol EZPlayerCustom: EZPlayerDelegate,EZPlayerCustomAction,EZPlayerHorizontalPan,EZPlayerGestureRecognizer {
}

