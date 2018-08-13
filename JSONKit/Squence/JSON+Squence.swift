//
//  JSON+Squence.swift
//  JSONKit
//
//  Created by William Lee on 2018/8/13.
//  Copyright © 2018 William Lee. All rights reserved.
//

import Foundation

// MARK: - Sequence
extension JSON: Sequence {
  
  public typealias Iterator = JSONIterator
  
  public func makeIterator() -> JSON.Iterator {
    
    return JSONIterator(self)
  }
  
}
