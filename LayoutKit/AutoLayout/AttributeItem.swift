//
//  AttributeItem.swift
//  LayoutKit
//
//  Created by William Lee on 2018/8/9.
//  Copyright © 2018 William Lee. All rights reserved.
//

import Foundation

struct AttributeItem {
  
  let attribute: NSLayoutAttribute
  
  let offset: CGFloat
  
  init(_ attribute: NSLayoutAttribute, offset: CGFloat = 0) {
    
    self.attribute = attribute
    self.offset = offset
  }
}
