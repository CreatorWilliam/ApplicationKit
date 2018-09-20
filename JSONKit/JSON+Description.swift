//
//  JSON+Description.swift
//  JSONKit
//
//  Created by William Lee on 2018/8/17.
//  Copyright © 2018 William Lee. All rights reserved.
//

import Foundation

// MARK: - CustomStringConvertible
extension JSON: CustomStringConvertible {
  
  public var description: String { return self.customDescription() }
  
}

// MARK: - CustomDebugStringConvertible
extension JSON: CustomDebugStringConvertible {
  
  public var debugDescription: String { return self.customDescription() }
  
}

// MARK: - PrettyJSONDescription
private extension JSON {
  
  func customDescription(options: JSONSerialization.WritingOptions = .prettyPrinted) -> String {
    
    var jsonObject: Any
    if let object = self.dictionary { jsonObject = object }
    else if let object = self.array { jsonObject = object }
    else { return "\(self.data ?? "ERROR: Empty")" }
    
    guard let descriptionData = try? JSONSerialization.data(withJSONObject: jsonObject, options: options) else { return "ERROR: JSONSerialization FAILED" }
    return String(data: descriptionData, encoding: .utf8) ?? "ERROR: ENCODING FAILED"
  }
  
}









