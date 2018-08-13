//
//  JSON+File.swift
//  JSONKit
//
//  Created by William Lee on 2018/8/13.
//  Copyright © 2018 William Lee. All rights reserved.
//

import Foundation

// MARK: - JSON Save
public extension JSON {
  
  /// 保存JSON到指定URL
  ///
  /// - Parameter url: url
  /// - Returns: false: 保存失败，true：保存成功
  @discardableResult
  func save(to url: URL) -> Bool {
    
    guard let objcet = self.data else { return false }
    
    do {
      
      let data = try JSONSerialization.data(withJSONObject: objcet, options: .prettyPrinted)
      
      if FileManager.default.fileExists(atPath: url.absoluteString) {
        
        try FileManager.default.removeItem(at: url)
      }
      
      try data.write(to: url)
      
      return true
      
    } catch {
      
      return false
    }
    
  }
  
}
