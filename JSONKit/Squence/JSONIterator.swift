//
//  JSONIterator.swift
//  JSONKit
//
//  Created by William Lee on 2018/8/9.
//  Copyright © 2018 William Lee. All rights reserved.
//

import Foundation

public struct JSONIterator {
  
  var arrayIterator: IndexingIterator<[Any]>?
  var dictionaryIterator: DictionaryIterator<String, Any>?
  
  init(_ json: JSON) {
    
    self.arrayIterator = json.array?.makeIterator()
    self.dictionaryIterator = json.dictionary?.makeIterator()
  }
  
}

// MARK: - IteratorProtocol
extension JSONIterator: IteratorProtocol {
  
  /// 1、String表示字典Key，数组的时候该值为空字符 ""
  /// 2、JSON表示对应数组索引的值或字典键的值
  public typealias Element = JSONIteratorElement
  
  public mutating func next() -> Element? {
    
    if let value = self.arrayIterator?.next() {
      
      return JSONIteratorElement("", JSON(value))
    }
    
    if let (key, value) = self.dictionaryIterator?.next() {
      
      return JSONIteratorElement(key, JSON(value))
    }
    
    return nil
  }
  
}









