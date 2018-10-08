//
//  SandBox.swift
//  DebugKit
//
//  Created by William Lee on 2018/10/7.
//  Copyright © 2018 William Lee. All rights reserved.
//

import Foundation

public struct SandBox {
  
  //public static let shared = SandBox()
  
  private init() { }
  
}

// MARK: - Public
public extension SandBox {
  
  static var home: SandBox.FileItem { return SandBox.FileItem(at: NSHomeDirectory()) }
  
}
