//
//  PopViewController.swift
//  ComponentKit
//
//  Created by William Lee on 2018/8/10.
//  Copyright © 2018 William Lee. All rights reserved.
//

import UIKit

open class PopViewController: UIViewController {
  
  /// 视图容器
  public let container = UIView()
  /// 预设容器视图所在位置
  public var estimatedPosition: Position = .center(0)
  /// 展示时候的方向
  public var showDirection: ShowDirection = .fromBottomToEstimate
  /// 展示动画时长
  public var showAnimationDuration: TimeInterval = 0.5
  /// 消失时候的方向
  public var hideDirection: HideDirection = .fromCurrentToBottom
  /// 隐藏动画时长
  public var hideAnimationDuration: TimeInterval = 0.5
  
  /// 是否触摸就消失
  public var isTouchHide: Bool = false
  
  public typealias Handle = () -> Void
  private var hideHandle: Handle?
  
  public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    
    self.modalPresentationStyle = .custom
  }
  
  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  open override func viewDidLoad() {
    super.viewDidLoad()
    
    self.setupUI()
  }
  
  open override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    self.show()
  }
  
  open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    
    if self.isTouchHide == false {
      
      super.touchesBegan(touches, with: event)
      return
    }
    
    for touch in touches {
      
      guard touch.view == self.view else { continue }
      self.hide()
      return
    }
  
    super.touchesBegan(touches, with: event)
  }
  
}

// MARK: - Public
public extension PopViewController {
  
  /// 内容视图在控制器视图中的位置
  enum Position {
    
    /// 顶部偏移
    case top(CGFloat)
    /// 中间位置偏移
    case center(CGFloat)
    /// 底部偏移
    case bottom(CGFloat)
  }
  
  /// 显示动画方向
  enum ShowDirection {
    
    /// 从底部向预设位置滑动显示
    case fromBottomToEstimate
    /// 从顶部向预设位置滑动显示
    case fromTopToEstimate

  }
  
  /// 隐藏动画方向
  enum HideDirection {
    
    /// 从当前位置向底部滑动隐藏
    case fromCurrentToBottom
    /// 从当前位置向顶部滑动隐藏
    case fromCurrentToTop
  }
  
  /// 展示PopViewController
  ///
  /// - Parameters:
  ///   - showHandle: 在展示后执行
  ///   - hideHadnle: 在隐藏后执行
  func show(complete showHandle: Handle? = nil, hideComplete hideHadnle: Handle? = nil) {
    
    // 计算隐藏Container的偏移量
    var hideOffset = UIScreen.main.bounds.height

    switch self.showDirection {
    case .fromTopToEstimate: hideOffset *= -1
    case .fromBottomToEstimate: hideOffset *= 1
    }
    
    // 设置起点位置
    self.container.layout.update { (make) in
      
      switch self.estimatedPosition {
      case .top(_): make.top(hideOffset).equal(self.view)
      case .center(_): make.centerY(hideOffset).equal(self.view)
      case .bottom(_): make.bottom(hideOffset).equal(self.view)
      }
    }
    self.view.layoutIfNeeded()
    
    // 设置终点位置
    self.container.layout.update { (make) in
      
      switch self.estimatedPosition {
      case .top(let offset): make.top(offset).equal(self.view)
      case .center(let offset): make.centerY(offset).equal(self.view)
      case .bottom(let offset): make.bottom(offset).equal(self.view)
      }
    }
    
    // 创建出现动画
    UIView.animate(withDuration: self.showAnimationDuration, animations: {
      
      self.view.layoutIfNeeded()
      
    }, completion: { (isFinished) in
      
      showHandle?()
    })
  }
  
  /// 隐藏PopViewController
  ///
  /// - Parameter handle: 在隐藏的时候执行
  func hide(complete handle: (() -> Void)? = nil) {
    
    // 计算隐藏Container的偏移量
    var hideOffset = UIScreen.main.bounds.height
    
    switch self.hideDirection {
    case .fromCurrentToTop: hideOffset *= -1
    case .fromCurrentToBottom: hideOffset *= 1
    }
    
    // 设置终点点位置
    self.container.layout.update { (make) in
      
      switch self.estimatedPosition {
      case .top(_): make.top(hideOffset).equal(self.view)
      case .center(_): make.centerY(hideOffset).equal(self.view)
      case .bottom(_): make.bottom(hideOffset).equal(self.view)
      }
    }
    
    UIView.animate(withDuration: self.hideAnimationDuration, animations: {
      
      self.view.layoutIfNeeded()
      
    }, completion: { (isFinished) in
      
      self.hideHandle?()
      handle?()
      self.dismiss(animated: false)
    })
  }

}

// MARK: - Setup
private extension PopViewController {
  
  func setupUI() {
    
    self.view.backgroundColor = UIColor.black.withAlphaComponent(0.7)
    
    self.container.layer.backgroundColor = UIColor.white.cgColor
    self.container.layer.cornerRadius = 10
    self.view.addSubview(self.container)
    self.container.layout.add { (make) in
      
      make.centerX().equal(self.view)
      switch self.estimatedPosition {
      case .top(let offset): make.top(offset).equal(self.view)
      case .center(let offset): make.centerY(offset).equal(self.view)
      case .bottom(let offset): make.bottom(offset).equal(self.view)
      }
    }
    
  }
  
}

// MARK: - Action
private extension PopViewController {
  
}

// MARK: - Network
private extension PopViewController {
  
}

// MARK: - Utiltiy
private extension PopViewController {
  
}













