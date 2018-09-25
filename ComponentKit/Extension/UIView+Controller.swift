//
//  UIView+Controller.swift
//  ComponentKit
//
//  Created by William Lee on 26/12/17.
//  Copyright © 2018 William Lee. All rights reserved.
//

import UIKit

public extension UIView {
  
  public func wm_viewController() -> UIViewController? {
    
    var nextResponder: UIResponder? = self
    
    repeat {
      
      nextResponder = nextResponder?.next
      
      if let viewController = nextResponder as? UIViewController { return viewController }
      
    } while nextResponder != nil
    
    return nil
  }
  
}
