//
//  JSONIteratorElement.swift
//  JSONKit
//
//  Created by William Lee on 2018/8/13.
//  Copyright © 2018 William Lee. All rights reserved.
//

import Foundation

public struct JSONIteratorElement {
  
  public let key: String
  public let json: JSON
  
  init(_ key: String, _ json: JSON) {
    
    self.key = key
    self.json = json
  }
  
}










