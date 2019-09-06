//
//  GenderPicker.swift
//  ComponentKit
//
//  Created by William Lee on 23/12/17.
//  Copyright © 2018 William Lee. All rights reserved.
//

import ApplicationKit
import UIKit

public struct GenderPicker {
  
  /// 性别
  ///
  /// - unknow: 未知
  /// - male: 男性
  /// - female: 女性
  public enum Gender {
    
    case unknow
    
    case male
    case female
    
  }
  
  private var selectHandle: ((Gender) -> Void)?
}

// MARK: - Public
public extension GenderPicker {
  
  static func open(withHandle handle: @escaping (Gender) -> Void) {
    
    var picker = GenderPicker()
    picker.selectHandle = handle
    
    let alertController = UIAlertController(title: "选择性别", message: nil, preferredStyle: .actionSheet)
    
    alertController.addAction(UIAlertAction(title: "取消", style: .cancel, handler: { (action) in
      
    }))
    
    alertController.addAction(UIAlertAction(title: "男", style: .default, handler: { (action) in
      
      picker.selectHandle?(.male)
    }))
    
    alertController.addAction(UIAlertAction(title: "女", style: .default, handler: { (action) in
      
      picker.selectHandle?(.female)
    }))
    
    DispatchQueue.main.async {
      
      Presenter.present(alertController, animated: true)
      
    }
    
  }
  
}
