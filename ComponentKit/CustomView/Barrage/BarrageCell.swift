//
//  BarrageCell.swift
//  ComponentKit
//
//  Created by William Lee on 2018/7/25.
//  Copyright © 2018 William Lee. All rights reserved.
//

import ApplicationKit
import UIKit

class BarrageCell: UIView {
  
  private let nameLabel = UILabel()
  private let contentLabel = UILabel()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    self.setupUI()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
  }
  
}

// MARK: - Public
extension BarrageCell {
  
  func update(with item: BarrageItem) {
   
    self.nameLabel.text = item.nickname
    self.contentLabel.text = item.content
  }
  
}

// MARK: - Setup
private extension BarrageCell {
  
  func setupUI() {
    
    self.contentLabel.font = Font.system(16)
    self.contentLabel.textColor = .white
  }
  
}

// MARK: - Action
private extension BarrageCell {
  
}
