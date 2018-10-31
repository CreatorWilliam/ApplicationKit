//
//  PlaceholderView.swift
//  ComponentKit
//
//  Created by William Lee on 2018/10/31.
//  Copyright © 2018 William Lee. All rights reserved.
//

import UIKit

public class PlaceholderView: UIView {
  
  private let imageView = UIImageView()
  private let titleLabel = UILabel()
  private let retryButton = UIButton(type: .custom)
  
  public override init(frame: CGRect) {
    super.init(frame: frame)
    
    self.setupUI()
  }
  
  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
}

// MARK: - PlaceholderViewCustomizable
extension PlaceholderView: PlaceholderViewCustomizable {
  
}

// MARK: - Setup
private extension PlaceholderView {
  
  func setupUI() {
    
  }
  
}
