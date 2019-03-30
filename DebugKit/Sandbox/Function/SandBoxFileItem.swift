//
//  SandBoxFileItem.swift
//  DebugKit
//
//  Created by William Lee on 2018/10/7.
//  Copyright © 2018 William Lee. All rights reserved.
//

import Foundation

public extension SandBox {
  
  struct FileItem {
    
    /// 文件路径
    public let path: String
    /// 文件名
    public private(set) var name: String
    /// 文件类型
    public private(set) var type: String?
    /// 是否为文件夹
    public var isDirectory: Bool { return FileAttributeType.typeDirectory.rawValue == self.type }
    /// 文件大小或者文件夹总大小
    public private(set) var size: Int64 = 0
    /// 创建时间
    public private(set) var creationDate: Date?
    /// 修改时间
    public private(set) var modificationDate: Date?
    /// 是否隐藏了扩展名
    public private(set) var isExtensionHidden: Bool = false
    /// 是否为应用根目录
    public var isHomeDirectory: Bool { return self.path == NSHomeDirectory() }
    /// 子文件
    public var subfiles: [SandBox.FileItem] = []
    
    
    
    public init(at path: String) {
      
      self.path = path
      
      let url = URL(fileURLWithPath: self.path)
      
      self.name = url.lastPathComponent
      
      do {
        
        let attributes = try FileManager.default.attributesOfItem(atPath: self.path)
        
        self.type = attributes[.type] as? String
        self.size = attributes[.size] as? Int64 ?? 0
        self.creationDate = attributes[FileAttributeKey.creationDate] as? Date
        self.modificationDate = attributes[FileAttributeKey.modificationDate] as? Date
        self.isExtensionHidden = attributes[FileAttributeKey.extensionHidden] as? Bool ?? false
        
        guard self.isDirectory == true else { return }
        // 文件夹不用计算自身大小
        self.size = 0
        let subfileNames = try FileManager.default.contentsOfDirectory(atPath: path)
        subfileNames.forEach({ self.subfiles.append(SandBox.FileItem(at: "\(self.path)/\($0)")) })
        self.subfiles.forEach({ self.size += $0.size })
        
        self.subfiles.sort(by: { (left, right) in
          
          
          switch (left.isDirectory, right.isDirectory) {
          case (false, true): return false
          case (true, false): return true
          case (true, true): return left.name.compare(right.name) == .orderedAscending
          case (false, false): return left.name.compare(right.name) == .orderedAscending
          }
        })
        
      } catch {
        
        print(error.localizedDescription)
      }
    }
  }
  
}

public extension SandBox.FileItem {
  
  /// 格式化后的文件大小
  var formateSize: String {
    
    var bSize = self.size
    var kbSize = bSize / 1024
    
    guard kbSize > 0 else { return "\(bSize) B" }
    bSize = bSize % 1024
    
    var mbSize = kbSize / 1024
    guard mbSize > 0 else { return String(format: "%d.%3d KB", kbSize, bSize) }
    kbSize = kbSize % 1024
    
    let gbSize = mbSize / 1024
    guard gbSize > 0 else { return String(format: "%d.%03d MB", mbSize, kbSize) }
    mbSize = mbSize % 1024
    
    return String(format: "%d.%3d GB", gbSize, mbSize)
  }
  
  /// 移除指定索引的子文件
  ///
  /// - Parameter index: 移除索引对应的文件
  mutating func remove(at index: Int) {
    
    self.subfiles.remove(at: index)
  }
}
