//
//  JSON.swift
//  JSONKit
//
//  Created by William Lee on 2018/8/9.
//  Copyright © 2018 William Lee. All rights reserved.
//

import Foundation

public struct JSON {
  
  /// 表示JSON解析过程中的消息
  public private(set) var messages: [String] = []
  
  /// JSON原始数据
  public private(set) var data: Any?
  /// JSON为字典的时候，有值
  public private(set) var dictionary: [String : Any]?
  /// JSON为数组的时候，有值
  public private(set) var array: [Any]?
  
  /// 根据JSON(字典、数组)数据创建JSON对象
  ///
  /// - Parameter jsonData: JSON数据
  public init(_ source: Any? = nil) {
    
    self.messages.append("JSON is init!")
    self.update(fromAny: source)
  }
  
}

// MARK: - Special Type Value
public extension JSON {
  
  var int: Int? {
    
    if let temp = self.data as? String {
      
      return Int(temp)
    }
    
    return self.value()
  }
  
  var double: Double? {
    
    if let temp = self.data as? String {
      
      return Double(temp)
    }
    
    return self.value()
  }
  
  var float: Float? {
    
    if let temp = self.data as? String {
      
      return Float(temp)
    }
    
    return self.value()
  }
  
  func value<T>() -> T? {
    
    return self.data as? T
  }
  
}

// MARK: - Update From Different Source
public extension JSON {
  
  /// 接收URL/Data/[String: Any]/[Any]进行更新JSON数据,Any必须是JSON支持的类型
  ///
  /// - Parameter source: URL/Data/JSONO对象
  mutating func update(fromAny source: Any?) {

    self.append("Will Update from Source")
    guard let source = source else {

      self.append("Source is nil")
      return
    }

    if let url = source as? URL {

      self.update(fromURL: url)
      return
    }
    
    if let string = source as? String {
      
      self.update(fromString: string)
      return
    }
    
    if let data = source as? Data {

      self.update(fromData: data)
      return
    }

    if let dictionary = source as? [String : Any] {

      self.update(fromDictionary: dictionary)
      return
    }

    if let array = source as? [Any] {

      self.update(fromArray: array)
      return
    }

    if let json = source as? JSON {

      self.update(fromJSON: json)
      return
    }

    self.append("Source isn't URL, JSON String, Data, [String: Any], [Any], JSON")
  }
  
  /// 从指定URL地址获取JSON数据
  ///
  /// - Parameter url: 获取JSON数据的URL
  mutating func update(fromURL url: URL) {
    
    guard let data = try? Data(contentsOf: url) else {
      
      self.append("Fetch json data failed from URL: \(url)")
      return
    }
    self.append("Update from URL\(url)")
    self.update(fromData: data)
  }
  
  mutating func update(fromString string: String) {
    
    guard let data = string.data(using: .utf8) else {
      
      self.append("\(string) isn't json string")
      return
    }
    self.append("Update from String\(string)")
    self.update(fromData: data)
  }
  
  /// 使用二进制的JSON数据更新
  ///
  /// - Parameter jsonData: JSON数据：[Any]、[String: Any]
  mutating func update(fromData data: Data) {
    
    do {
      
      let jsonObject = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
      
      self.append("Update from Data")
      if let dictionary = jsonObject as? [String : Any] {
        
        self.update(fromDictionary: dictionary)
        return
      }
      
      if let array = jsonObject as? [Any] {
        
        self.update(fromArray: array)
        return
      }
      
    } catch {
      
      self.append("Json Serialization failed reason: \(error.localizedDescription)")
    }
  }
  
  /// 使用JSON字典进行数据更新
  ///
  /// - Parameter dictionary: JSON字典[String: Any]
  mutating func update(fromDictionary dictionary: [String: Any]) {
    
    self.data = dictionary
    self.dictionary = dictionary
    self.append("Update Json from dictionary successfully")
  }
  
  /// 使用JSON数组进行数据更新
  ///
  /// - Parameter array: JSON数组
  mutating func update(fromArray array: [Any]) {
    
    self.data = array
    self.array = array
    self.append("Update Json from array successfully")
  }
  
  /// 使用另一个JSON对象进行数据更新
  ///
  /// - Parameter json: JSON对象
  mutating func update(fromJSON json: JSON) {
    
    self.data = json.data
    self.array = json.array
    self.dictionary = json.dictionary
    self.append("Update Json from other json successfully")
  }
  
}

// MARK: - Subscript
public extension JSON {
  
  /// 根据键值获取字典
  ///
  /// - Parameter key: 获取值的Key
  subscript<T>(_ key: String) -> T? {
    
    if T.self is Int.Type, let value: String = self.dictionary?[key] as? String {
      
      return Int(value) as? T
    }
    if T.self is Double.Type, let value: String = self.dictionary?[key] as? String {
      
      return Double(value) as? T
    }
    if T.self is Float.Type, let value: String = self.dictionary?[key] as? String {
      
      return Float(value) as? T
    }
    return self.dictionary?[key] as? T
  }
  
  /// 根据键值获取子JSON，用于多级取值
  ///
  /// - Parameter key: 子JSON的键值
  subscript(_ key: String) -> JSON {
    
    return JSON(self.dictionary?[key])
  }
  
  /// 根据索引获取子JSON，用于多级取值
  ///
  /// - Parameter index: 子JSON的索引
  subscript(_ index: Int) -> JSON {
    
    var json = JSON()
    
    guard index < self.array?.count ?? 0 else {
      
      json.messages.append("Index out of range")
      return json
    }
    json.update(fromAny: self.array?[index])
    return json
  }
  
}

// MARK: - Utility
private extension JSON {
  
  /// 用于记录解析过程中，每一步的信息
  ///
  /// - Parameter message: 解析的消息
  mutating func append(_ message: String) {
   
    #if DEBUG
    self.messages.append(message)
    #endif
  }
  
}





