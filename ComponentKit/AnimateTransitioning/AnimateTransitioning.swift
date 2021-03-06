//
//  AnimateTransitioning.swift
//  ComponentKit
//
//  Created by William Lee on 2019/8/5.
//  Copyright © 2019 William Lee. All rights reserved.
//

import ApplicationKit

public class AnimateTransitioning: NSObject {
  
  /// 蒙版颜色
  public var maskColor: UIColor = UIColor.black.withAlphaComponent(0.4)
  /// 是否点击蒙版关闭
  public var isTouchMaskHide: Bool = true
  
  /// 内部持有延长其生命期
  private static var shared: AnimateTransitioning?
  
  public enum AnimationType {
    case bottomToTop
    case topToBottom
    case rightToLeft
    case leftToRight
  }
  /// 指定显示时动画
  public var presentAnimationType: AnimationType = .bottomToTop
  /// 指定消失时动画
  public var dismissAnimationType: AnimationType = .topToBottom
  
  /// 用于描述当前动画处于哪一步
  private enum Step {
    /// 模态动画的present阶段
    case present
    /// 模态动画的dismiss阶段
    case dismis
    /// 导航动画的push阶段
    case push
    /// 导航动画的pop阶段
    case pop
  }
  
  private weak var containerView: UIView?
  private weak var fromViewController: UIViewController?
  private weak var toViewController: UIViewController?
  
  /// 保存当前动画所处的阶段
  private var step: Step = .present
  /// 用于点击背景退出
  private lazy var tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapDismiss))
  
  public override init() {
    super.init()
    
    AnimateTransitioning.shared = self
  }
  
}

// MARK: - Public
extension AnimateTransitioning {
  
}

// MARK: - UINavigationControllerDelegate
extension AnimateTransitioning: UINavigationControllerDelegate {
  
}

// MARK: - UIViewControllerTransitioningDelegate
extension AnimateTransitioning: UIViewControllerTransitioningDelegate {
  
  public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    
    step = .present
    return self
  }
  
  public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    
    step = .dismis
    return self
  }
  
  public func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
    
    return nil
  }
  
  public func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
    
    return nil
  }
  
  public func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
    
    return nil
  }
  
}

// MARK: - UIViewControllerAnimatedTransitioning
extension AnimateTransitioning: UIViewControllerAnimatedTransitioning {
  
  public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
    
    return 0.3
  }
  
  public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
    
    toViewController = transitionContext.viewController(forKey: .to)
    fromViewController = transitionContext.viewController(forKey: .from)
    containerView = transitionContext.containerView
    
    switch step {
    case .present: animatePresentTransition(using: transitionContext, animationType: presentAnimationType)
    case .dismis: animateDismisTransition(using: transitionContext, animationType: dismissAnimationType)
    default: break
    }
  }
  
  public func animationEnded(_ transitionCompleted: Bool) {
    
  }
  
}

// MARK: - Action
private extension AnimateTransitioning {
  
  @objc func tapDismiss(_ sender: UITapGestureRecognizer) {
    
    Presenter.back()
  }
  
}

// MARK: - Utility
private extension AnimateTransitioning {
  
  func animatePresentTransition(using transitionContext: UIViewControllerContextTransitioning, animationType: AnimationType) {
    
    guard let toViewController = toViewController else { return }
    guard let containerView = containerView else { return }
    
    containerView.backgroundColor = maskColor
    
    containerView.addSubview(toViewController.view)
    switch animationType {
    case .bottomToTop: toViewController.view.frame.origin.y = UIScreen.main.bounds.height
    case .topToBottom: toViewController.view.frame.origin.y = -UIScreen.main.bounds.height
    case .rightToLeft: toViewController.view.frame.origin.x = UIScreen.main.bounds.width
    case .leftToRight: toViewController.view.frame.origin.x = -UIScreen.main.bounds.width
    }
//    toViewController.view.frame.origin.y = UIScreen.main.bounds.height
    
    if isTouchMaskHide == true {
      
      toViewController.view.addGestureRecognizer(tapGestureRecognizer)
    }
    
    UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
      
//      toViewController.view.frame.origin.y = 0
      switch animationType {
      case .bottomToTop, .topToBottom:
        toViewController.view.frame.origin.y = 0
      case .rightToLeft, .leftToRight:
        toViewController.view.frame.origin.x = 0
      }
      
    }, completion: { (_) in
      
      transitionContext.completeTransition(true)
    })
  }
  
  func animateDismisTransition(using transitionContext: UIViewControllerContextTransitioning, animationType: AnimationType) {
    
    guard let fromViewController = fromViewController else { return }
    guard let toViewController = toViewController else { return }
    guard let containerView = containerView else { return }
    
    toViewController.view.removeGestureRecognizer(tapGestureRecognizer)
    
    containerView.addSubview(fromViewController.view)
    
    UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
      
      switch animationType {
      case .bottomToTop: fromViewController.view.frame.origin.y = -UIScreen.main.bounds.height
      case .topToBottom: fromViewController.view.frame.origin.y = UIScreen.main.bounds.height
      case .rightToLeft: fromViewController.view.frame.origin.x = -UIScreen.main.bounds.width
      case .leftToRight: fromViewController.view.frame.origin.x = UIScreen.main.bounds.width
      }
//      fromViewController.view.frame.origin.y = UIScreen.main.bounds.height
      
    }, completion: { (_) in
      
      transitionContext.completeTransition(true)
      AnimateTransitioning.shared = nil
    })
  }
  
}
