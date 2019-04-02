//
//  AttributeItem.swift
//  LayoutKit
//
//  Created by William Lee on 2018/8/9.
//  Copyright © 2018 William Lee. All rights reserved.
//

import UIKit

struct AttributeItem {
  
  let attribute: NSLayoutConstraint.Attribute
  
  let offset: CGFloat
  
  init(_ attribute: NSLayoutConstraint.Attribute, _ offset: CGFloat = 0) {
    
    self.attribute = attribute
    self.offset = offset
  }
  
}
