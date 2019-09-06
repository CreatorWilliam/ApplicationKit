//
//  SegmentViewCell.swift
//  ComponentKit
//
//  Created by William Lee on 2018/7/3.
//  Copyright © 2018 William Lee. All rights reserved.
//

import ApplicationKit
import UIKit

class SegmentViewCell: UICollectionViewCell {
  
  private let redPointView = UIView()
  private let badgeView = UIButton(type: .custom)
  private let titleButton = UIButton(type: .custom)
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    self.setupUI()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    self.badgeView.layer.cornerRadius = self.badgeView.bounds.height / 2.0
  }
  
  override var isSelected: Bool {
    
    set {
      
      super.isSelected = newValue
      self.titleButton.isSelected = newValue
    }
    
    get {
      
      return super.isSelected
    }
  }
  
}

// MARK: - SegmentBadgable
extension SegmentViewCell: SegmentViewCellBadgable {
  
  /// 更新角标
  ///
  /// - Parameter count: 角标显示数，nil表示隐藏，0表示小圆点，大于0显示对应的数字
  func updateBadge(_ count: Int?) {
    
    guard let badge = count else {
      
      self.badgeView.isHidden = true
      self.redPointView.isHidden = true
      self.badgeView.setTitle(nil, for: .normal)
      return
    }
    
    if badge > 0 {
      
      self.badgeView.isHidden = false
      self.redPointView.isHidden = true
      self.badgeView.setTitle("\(badge)", for: .normal)
      
    } else {
      
      self.badgeView.isHidden = true
      self.redPointView.isHidden = false
      self.badgeView.setTitle(nil, for: .normal)
      
    }
  }
  
}

// MARK: - SegmentCellable
extension SegmentViewCell: SegmentViewCellable {
  
  func update(with item: SegmentViewItemSourcable) {
    
    guard let item = item as? SegmentViewItem else { return }
    // 未选中图标
    if let name = item.normalImage {
      
      self.titleButton.setImage(UIImage(named: name), for: .normal)
      
    } else {
      
      self.titleButton.setImage(nil, for: .normal)
    }
    
    // 选中图标
    if let name = item.selectedImage {
      
      self.titleButton.setImage(UIImage(named: name), for: .selected)
      
    } else {
      
      self.titleButton.setImage(nil, for: .selected)
    }
    
    // 标题
    self.titleButton.setAttributedTitle(item.normalTitle, for: .normal)
    self.titleButton.setAttributedTitle(item.selectedTitle, for: .selected)
    
    self.updateBadge(item.badge)
  }
  
}

// MARK: - Setup
private extension SegmentViewCell {
  
  func setupUI() {
    
    self.contentView.backgroundColor = .clear
    
    self.titleButton.isUserInteractionEnabled = false
    self.titleButton.titleLabel?.adjustsFontSizeToFitWidth = true
    self.titleButton.titleLabel?.numberOfLines = 0
    self.contentView.addSubview(self.titleButton)
    self.titleButton.layout.add { (make) in
      
      make.top().bottom().leading().trailing().equal(self.contentView)
    }
    
    self.badgeView.isHidden = true
    self.badgeView.isUserInteractionEnabled = false
    self.badgeView.setTitle("", for: .normal)
    self.badgeView.layer.backgroundColor = UIColor(0xff4f4f).cgColor
    self.badgeView.titleLabel?.font = Font.system(10)
    self.badgeView.setTitleColor(.white, for: .normal)
    self.badgeView.contentEdgeInsets = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
    self.titleButton.addSubview(self.badgeView)
    self.badgeView.layout.add { (make) in
      
      make.centerX().equal(self.titleButton.titleLabel).trailing()
      make.centerY().equal(self.titleButton.titleLabel).top()
      make.width().greaterThanOrEqual(self.badgeView).height()
    }
    
    self.redPointView.isHidden = true
    self.redPointView.layer.backgroundColor = UIColor(0xff4f4f).cgColor
    self.redPointView.layer.cornerRadius = 3
    self.titleButton.addSubview(self.redPointView)
    self.redPointView.layout.add { (make) in
      
      make.centerX().equal(self.titleButton.titleLabel).trailing()
      make.centerY().equal(self.titleButton.titleLabel).top()
      make.height(6).width(6)
    }
    
  }
  
}
