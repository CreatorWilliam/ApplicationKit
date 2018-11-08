//
//  BarrageView.swift
//  VideoModule
//
//  Created by William Lee on 2018/7/25.
//  Copyright © 2018 飞进科技. All rights reserved.
//

import UIKit

class BarrageView: UIView {
  
  private var barrages: [BarrageItem] = []
  private let contentLabels: [UILabel] = []
  private var speed: CGFloat = 0
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    self.setupUI()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
}

extension BarrageView {
  
  func add(_ item: BarrageItem) {
    
    let contentView: UIButton = UIButton(type: .custom)
    contentView.isUserInteractionEnabled = false
    
//    contentView.setTitle(item.content, for: .normal)
//    contentView.titleLabel?.font = item.font
//    contentView.setTitleColor(item.color, for: .normal)
//    contentView.contentEdgeInsets = UIEdgeInsets(top: 5, left: 15, bottom: 5, right: 15)
//    let size: CGSize = contentView.sizeThatFits(CGSize(width: 999, height: 100))
//    let y = arc4random_uniform(UInt32(self.bounds.height - size.height))
//    contentView.frame = CGRect(origin: CGPoint(x: self.bounds.width, y: CGFloat(y)), size: size)
//    self.addSubview(contentView)
//
//    if item.isReply {
//
//      contentView.layer.backgroundColor = Adapter.white.withAlphaComponent(0.3).cgColor
//      contentView.layer.cornerRadius = contentView.frame.height / 2.0
//
//    }
    
//    let speed: CGFloat = self.bounds.width / 3.0
//    let duration = (size.width + self.bounds.width) / speed
//    
//    UIView.animate(withDuration: TimeInterval(duration), animations: {
//      
//      contentView.frame.origin.x = -size.width
//      
//    }, completion: { (isFinished) in
//      
//      contentView.removeFromSuperview()
//    })
    
  }
  
}

// MARK: - Setup
private extension BarrageView {
  
  func setupUI() {
    
    self.backgroundColor = .clear
    self.clipsToBounds = true
  }
  
}










