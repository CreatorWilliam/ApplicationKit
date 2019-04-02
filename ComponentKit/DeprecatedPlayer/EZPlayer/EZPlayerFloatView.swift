//
//  EZPlayerFloatView.swift
//  EZPlayer
//
//  Created by yangjun zhu on 2016/12/28.
//  Copyright © 2016年 yangjun zhu. All rights reserved.
//

import UIKit

open class EZPlayerFloatView: UIView, EZPlayerCustomAction {
  var autohidedControlViews = [UIView]()
  
  
  /*
   // Only override draw() if you perform custom drawing.
   // An empty implementation adversely affects performance during animation.
   override func draw(_ rect: CGRect) {
   // Drawing code
   }
   */
  
  weak var player: EZPlayer?
  func playPauseButtonPressed(_ sender: Any){
  }
  func fullEmbeddedScreenButtonPressed(_ sender: Any){
  }
  func audioSubtitleCCButtonPressed(_ sender: Any){
  }
  
  @IBAction func backButtonPressed(_ sender: Any){
    self.player?.backButtonBlock?(.float)
  }
  
}


extension EZPlayerFloatView: EZPlayerGestureRecognizer {
  
  func player(_ player: EZPlayer, singleTapGestureTapped singleTap: UITapGestureRecognizer)
  {
    if player.isPlaying {
      player.pause()
    }else{
      player.play()
    }
  }
  
  func player(_ player: EZPlayer, doubleTapGestureTapped doubleTap: UITapGestureRecognizer) {
    player.toFull()
  }
  
  
}
