//
//  Regular.swift
//  ComponentKit
//
//  Created by William Lee on 26/12/17.
//  Copyright © 2018 William Lee. All rights reserved.
//

import Foundation

public struct Regular {
  
  static func check(_ kind: Kind, content: String?) -> Bool {
    
    let predicate = NSPredicate(format: "SELF MATCHES %@", kind.rawValue)
    
    return predicate.evaluate(with: content)
  }
  
  //验证内容是否只包含空格，换行符，制表符
  static func isValidateText(_ text: String) -> Bool {
    
    do {
      
      let regularExpression = try NSRegularExpression(pattern: "[^ \r\t\n]",
                                                      options: .caseInsensitive)
      let result = regularExpression.firstMatch(in: text,
                                                options: .reportProgress,
                                                range: NSMakeRange(0, text.count))
      
      if let _ = result { return true }
      
    } catch {
      
      print("\(error.localizedDescription)")
    }
    
    return false
  }
  
}

// MARK: - Kind
public extension Regular {
  
  enum Kind : String {
    
    case email = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
    case mobil = "^(1)\\d{10}$" //^((13[0-9])|(15[0-9])|(17[678])|(18[0-9])|(14[57]))[0-9]{8}$
    case account = "^[A-Za-z0-9]{4,20}+$"
    case password = "^[a-zA-Z0-9]{6,16}+$"
    case identityCard = "^(\\d{15}|\\d{18})$"
    case bankCard = "^(\\d{15,30})"
    case bankLast4Byte = "^(\\d{4})"
    
    case month = "(^(0)([0-9])$)|(^(1)([0-2])$)"
    case year = "^([1-3])([0-9])$"
    
    case number = "^[0-9]*$"
    //case nickName = "([\u4e00-\u9fa5]{2,5})(&middot;[\u4e00-\u9fa5]{2,5})*
    //case carNo = "^[\u4e00-\u9fa5]{1}[a-zA-Z]{1}[a-zA-Z_0-9]{4}[a-zA-Z_0-9_\u4e00-\u9fa5]$"
    //case carType = "^[\u4E00-\u9FFF]+$"
    
  }
  
}

// MARK: - Regular
public extension String {
  
  func check(_ kind: Regular.Kind) -> Bool {
    
    return Regular.check(kind, content: self)
  }
  
  func isValidate() -> Bool {
    
    return Regular.isValidateText(self)
  }
}
