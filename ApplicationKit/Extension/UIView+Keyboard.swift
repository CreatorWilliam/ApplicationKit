//
//  UIView+Keyboard.swift
//  ComponentKit
//
//  Created by William Lee on 20/12/17.
//  Copyright © 2018 William Lee. All rights reserved.
//

import UIKit

// MARK: - KeybaordAccessoryView
public extension UIView {
  
  fileprivate struct KeyboardExtensionKey {
    
    static var toolBarKey: Void?
    
  }
  
  func showKeyboardToolBar(tintColor: UIColor = .black) {
    
    if let textView = self as? UITextView {
      
      textView.inputAccessoryView = self.keyboardToolBar
      
    } else if let textField = self as? UITextField {
      
      textField.inputAccessoryView = self.keyboardToolBar
      
    } else {
      
      // Nothing
    }
    self.keyboardToolBar.items?.forEach({ $0.tintColor = tintColor })
  }
  
  fileprivate var keyboardToolBar: UIToolbar {
    
    if let temp = objc_getAssociatedObject(self, &KeyboardExtensionKey.toolBarKey) as? UIToolbar { return temp }
    
    let temp = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 30))
    let closeItem = UIBarButtonItem(title: "关闭键盘", style: .plain, target: self, action: #selector(component_clickClose(_:)))
    //closeItem.tintColor = .black
    closeItem.setTitleTextAttributes([NSAttributedString.Key.font : UIFont.systemFont(ofSize: 15)], for: .normal)
    let fixedItem = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
    fixedItem.width = 13
    let flexibleItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
    temp.items = [flexibleItem, closeItem, fixedItem]
    temp.barTintColor = .white
    temp.backgroundColor = .white
    
    objc_setAssociatedObject(self, &KeyboardExtensionKey.toolBarKey, temp, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    return temp
  }
  
  @objc fileprivate func component_clickClose(_ sender: UIBarButtonItem) {
    
    self.resignFirstResponder()
  }
  
}
