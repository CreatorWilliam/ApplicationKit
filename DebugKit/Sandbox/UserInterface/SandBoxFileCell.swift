//
//  SandBoxFileCell.swift
//  DebugKit
//
//  Created by William Lee on 2018/10/7.
//  Copyright © 2018 William Lee. All rights reserved.
//

import UIKit

public extension SandBox {
  
  class FileCell: UITableViewCell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
      super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
      
      self.selectionStyle = .none
      self.contentView.backgroundColor = .black
      self.backgroundColor = .black
      
      self.textLabel?.font = UIFont.systemFont(ofSize: 16)
      self.textLabel?.numberOfLines = 0
      self.textLabel?.textColor = .white
      
      self.detailTextLabel?.font = UIFont.systemFont(ofSize: 14)
      self.detailTextLabel?.textColor = .white
      
      //self.tintColor = .green
    }
    
    required init?(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }
    
  }
  
}

extension SandBox.FileCell {
  
  func update(with item: SandBox.FileItem) {
    
    self.textLabel?.text = item.name
    self.detailTextLabel?.text = item.formateSize
    self.accessoryType = (item.isDirectory ? .disclosureIndicator : .none)
  }
  
}
