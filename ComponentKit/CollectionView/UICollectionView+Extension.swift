//
//  UICollectionView+Extension.swift
//  ComponentKit
//
//  Created by William Lee on 27/12/17.
//  Copyright © 2018 William Lee. All rights reserved.
//

import UIKit

public extension UICollectionView {
  
  func register(cells: [ReuseItem]) {
    
    cells.forEach { self.register($0.class, forCellWithReuseIdentifier: $0.id) }
  }
  
}
