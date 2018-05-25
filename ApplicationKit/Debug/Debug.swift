//
//  Debug.swift
//  ApplicationKit
//
//  Created by William Lee on 2018/5/16.
//  Copyright © 2018 William Lee. All rights reserved.
//

import Foundation

public func DebugLog(_ items: Any...) {
  #if DEBUG
  
  guard items.count > 0 else { return }
  if items.count > 1 {
    
    print("DebugLog", items)
    
  } else if let item = items.first, items.count == 1 {
    
    print("DebugLog", item)
    
  } else {
    
    return
  }
  
  #endif
}
