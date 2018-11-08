//
//  OptionsPopView.swift
//  ComponentKit
//
//  Created by William Lee on 23/03/2018.
//  Copyright © 2018 William Lee. All rights reserved.
//

import UIKit

public class OptionsPopView: UIView {
  
  private var optionViews: [OptionActionView] = []
  
  private let arrowView = UIView()
  private let contentView = UIView()
  
  private var showHandle: ShowHandle?
  private var hideHandle: HideHandle?
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    self.setupView()
    self.setupLayout()
  }
  
  required public init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    
    touches.forEach { (touch) in
      
      if touch.view == self { self.hide() }
    }
  }
  
}

// MARK: - Public
public extension OptionsPopView {
  
  /// 显示
  func show() {
    
    self.showHandle?()
    self.isHidden = false
  }
  
  /// 隐藏
  func hide() {
    
    self.hideHandle?()
    self.isHidden = true
  }
  
  typealias ShowHandle = () -> Void
  typealias HideHandle = () -> Void
  /// 更新显示/隐藏时的回调
  func updateHandle(show showHandle: @escaping ShowHandle, hide hideHandle: @escaping HideHandle) {
    
    self.showHandle = showHandle
    self.hideHandle = hideHandle
  }
  
  /// 添加选项
  func addOption(image: String? = nil, title: String, target: Any, action: Selector) {
    
    let optionView = OptionActionView()
    optionView.update(image: image, title: title, target: target, action: action)
    self.contentView.addSubview(optionView)
    optionView.layout.add { (make) in
      
      if let last = self.optionViews.last {
        
        make.top(1).equal(last).bottom()
        
      } else {
        
        make.top().equal(self.contentView)
      }
      make.leading().trailing().equal(self.contentView)
      make.bottom().lessThanOrEqual(self.contentView)
      make.height(44)
    }
    self.optionViews.append(optionView)
  }
  
  func removeAllOptions() {
    
    self.optionViews.forEach({ $0.removeFromSuperview() })
    self.optionViews.removeAll()
  }
  
  func update(images: [String] = [], titles: [String] = [], badges: [Int] = []) -> Void {
    
    self.optionViews.enumerated().forEach { (offset, optionView) in
      
      if offset < images.count { optionView.update(image: images[offset]) }
      
      if offset < titles.count { optionView.update(title: titles[offset]) }
      
      if offset < badges.count { optionView.update(badge: badges[offset]) }
      
    }
  }
  
}

// MARK: - Setup
private extension OptionsPopView {
  
  func setupView() {
    
    self.isHidden = true
    self.backgroundColor = UIColor.black.withAlphaComponent(0.3)
    
    let size = CGSize(width: 14, height: 10)
    let path = UIBezierPath()
    path.move(to: CGPoint(x: size.width / 2.0, y: 0))
    path.addLine(to: CGPoint(x: 0, y: size.height))
    path.addLine(to: CGPoint(x: size.width, y: size.height))
    path.lineWidth = 1.0
    
    let arrowLayer = CAShapeLayer()
    arrowLayer.path = path.cgPath
    
    self.arrowView.layer.mask = arrowLayer
    self.arrowView.backgroundColor = .white
    self.addSubview(self.arrowView)
    
    self.contentView.layer.cornerRadius = 5
    self.contentView.clipsToBounds = true
    self.contentView.backgroundColor = UIColor(0xeeeeee)
    self.addSubview(self.contentView)
  }
  
  func setupLayout() {
    
    self.arrowView.layout.add { (make) in
      
      make.top().trailing(-20).equal(self)
      make.height(10).width(14)
    }
    
    self.contentView.layout.add { (make) in
      
      make.top(10).trailing(-10).equal(self)
      //make.width(140)
    }
    
  }
  
}

// MARK: - Action
private extension OptionsPopView {
  
}














