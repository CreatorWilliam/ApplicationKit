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
  var content = "\(items)"
  if content.hasPrefix("[") { content.removeFirst() }
  if content.hasSuffix("]") { content.removeLast() }
  print("DebugLog \(content)")
  #endif
}
