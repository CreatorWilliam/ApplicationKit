//
//  PopupMenuItem.swift
//  ComponentKit
//
//  Created by William Lee on 2019/2/20.
//  Copyright © 2019 William Lee. All rights reserved.
//

import Foundation

public struct PopupMenuItem {
  
  let title: String?
  let imageName: String?
  let imageURL: String?
  
  public init(title: String?, imageName name: String?) {
    
    self.title = title
    self.imageName = name
    self.imageURL = nil
  }
  
  public init(title: String?, imageURL url: String?) {
    
    self.title = title
    self.imageName = nil
    self.imageURL = url
  }
  
}
