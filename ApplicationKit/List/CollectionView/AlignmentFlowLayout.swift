//
//  AlignmentFlowLayout.swift
//  ComponentKit
//
//  Created by  William Lee on 05/03/2018.
//  Copyright © 2018 William Lee. All rights reserved.
//

import UIKit

public class AlignmentLayout: UICollectionViewFlowLayout {
  
  private var alignment: Alignment = .default
  
  public init(style: Style, interitemSpacing: CGFloat = 0, lineSpacing: CGFloat = 0) {
    super.init()
    
    // 避免Style的方向与实际设置不一致的问题
    switch style {
    case .horizontalLeft, .horizontalCenter, .horizontalRight: self.scrollDirection = .horizontal
    case .verticalLeft, .verticalCenter, .verticalRight: self.scrollDirection = .vertical
    default: break
    }
    
    switch style {
    case .verticalLeft, .horizontalLeft: self.alignment = .left
    case .verticalCenter, .horizontalCenter: self.alignment = .center
    case .verticalRight, .horizontalRight: self.alignment = .right
    default: break
    }
    
    self.minimumInteritemSpacing = interitemSpacing
    self.minimumLineSpacing = lineSpacing
    
  }
  
  required public init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override public func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
    
    guard let attributes = super.layoutAttributesForElements(in: rect) else { return nil }
    
    switch (self.scrollDirection, self.alignment) {
    case (.vertical, .left): self.verticalLeft(with: attributes)
    case (.vertical, .center): self.verticalCenter(with: attributes)
    case (.vertical, .right): self.verticalRight(with: attributes)
    default: break
    }
    
    return attributes
  }
  
}

// MARK: - enum Style
public extension AlignmentLayout {
  
  enum Style {
    
    /// 水平居左
    case horizontalLeft
    /// 水平居中（待定，目前自行调整itemSize达到居中效果）
    case horizontalCenter
    /// 水平居右（待定）
    case horizontalRight
    
    /// 竖直居左
    case verticalLeft
    /// 竖直居中
    case verticalCenter
    /// 竖直居右
    case verticalRight
    
    /// 系统默认
    case none
  }
  
}

// MARK: - enum Alignment
private extension AlignmentLayout {
  
  enum Alignment {
    
    /// 居左
    case left
    /// 居中
    case center
    /// 居右
    case right
    
    /// 系统默认布局
    case `default`
  }
  
}

// MARK: - Vertical Alignment
private extension AlignmentLayout {
  
  /// 竖直居左
  func verticalLeft(with attributes: [UICollectionViewLayoutAttributes]) {
    
    // 左上角起始点
    var leftX: CGFloat = 0
    var topY: CGFloat = 0
    
    attributes.forEach({ (attribute) in
      
      //判断是否是同一行
      if attribute.frame.minY != topY {
        
        // 不是同一行，则设置新一行的起始点X、Y
        leftX = attribute.frame.minX
        topY = attribute.frame.minY
      }
      
      // 设置X
      attribute.frame.origin.x = leftX
      // 配置下一个元素的起始点X
      leftX += attribute.frame.width + self.minimumInteritemSpacing
    })
    
  }
  
  /// 竖直居中
  func verticalRight(with attributes: [UICollectionViewLayoutAttributes]) {
    
    guard let collectionView = self.collectionView else { return }
    
    // 右上角起始点
    let rightX: CGFloat = collectionView.bounds.width - collectionView.contentInset.right - collectionView.contentInset.left
    var topY: CGFloat = 0
    
    var rowAttributes: [UICollectionViewLayoutAttributes] = []
    attributes.forEach({ (attribute) in
      
      //判断是否是同一行
      if attribute.frame.origin.y != topY {
        
        /// 不是同一行，清除缓存的上一行所有元素
        rowAttributes.removeAll()
        topY = attribute.frame.minY
      }
      
      // 将同一行的元素向左移动
      for sameRowAttribute in rowAttributes {
        
        sameRowAttribute.frame.origin.x -= (attribute.bounds.width + self.minimumInteritemSpacing)
      }
      
      //将新的元素放置到行尾
      attribute.frame.origin.x = (rightX - attribute.bounds.width)
      
      // 将元素加入行元素中，等待下次进行偏移
      rowAttributes.append(attribute)
    })
    
  }
  
  /// 竖直居右
  func verticalCenter(with attributes: [UICollectionViewLayoutAttributes]) {
    
    guard let collectionView = self.collectionView else { return }
    
    // 元素居中对齐的中点X
    let midX: CGFloat = collectionView.bounds.width / 2
    
    // 记录下一个元素的原点
    var topY: CGFloat = 0
    var sumWidth: CGFloat = 0
    
    var rowAttributes: [UICollectionViewLayoutAttributes] = []
    attributes.forEach({ (attribute) in
      
      //判断是否是同一行
      if attribute.frame.origin.y != topY {
        
        /// 不是同一行，清除缓存的上一行所有元素
        rowAttributes.removeAll()
        topY = attribute.frame.minY
        sumWidth = 0
      }
      
      // 将同一行的元素向左移动
      for sameRowAttribute in rowAttributes {
        
        sameRowAttribute.frame.origin.x -= (attribute.bounds.width / 2 + self.minimumInteritemSpacing / 2)
      }
      
      // 将元素加入行元素中，等待下次进行偏移
      rowAttributes.append(attribute)
      //将新的元素放置到行尾
      attribute.frame.origin.x = midX + sumWidth / 2 - attribute.frame.width / 2
      // 统计下次计算用的宽度
      sumWidth += (attribute.frame.width + self.minimumInteritemSpacing)
    })
    
  }
  
}
