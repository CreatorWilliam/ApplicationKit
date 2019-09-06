//
//  Placeholder.swift
//  ComponentKit
//
//  Created by William Lee on 2018/10/30.
//  Copyright © 2018 William Lee. All rights reserved.
//

import UIKit

/// 占位符
public struct Placeholder {
  
  public let name: String
  public var image: UIImage? { return UIImage(named: self.name) }
  
  public init(_ name: String) { self.name = name }
  
}
