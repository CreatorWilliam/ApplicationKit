//
//  ImageKit.swift
//  ImageKit
//
//  Created by William Lee on 2018/10/9.
//  Copyright © 2018 William Lee. All rights reserved.
//

import UIKit

public struct ImageKit {
  
}

public extension ImageKit {
  
  /// 裁剪模式不会造成图片比例失真，配合wm_draw函数使用
  ///
  /// - default: 按原图宽高比进行缩放，图片宽度等于给定（默认）宽度，图片高度可能不等于（大于或小于）给定（默认）高度
  /// - fill: 按原图宽高比进行缩放，填充给定（默认）大小，保证图片宽度等于给定（默认）的宽度，图片高度不小于给定（默认）的高度，或者图片高度等于给定（默认）的高度，图片宽度不小于给定（默认）的宽度
  /// - fit: 按原图宽高比进行缩放，适应给定（默认）大小，保证图片宽度等于给定（默认）的宽度，图片高度不大于给定（默认）的高度，或者图片高度等于给定（默认）的高度，图片宽度不大于给定（默认）的宽度
  enum DrawMode {
    
    case `default`
    case fill
    case fit
  }
  
}

public extension UIImageView {
  
  /// 设置图片
  ///
  /// - Parameters:
  ///   - url: 要设置的图片地址，类型包括URL，可以转化为URL的String
  ///   - placeholder: 占位图，可以是UIImage，也可以是通过能通过UIImage(named:)生成图片的本地图片名
  ///   - isForceRefresh: 是否强制刷新
  func setImage(with url: Any?, placeholder: Any? = nil, isForceRefresh: Bool = false) {
    
    let placeholder: UIImage? = self.prepare(with: placeholder)
    let imageURL: URL? = self.prepare(with: url)
    
    var options: KingfisherOptionsInfo?
    if isForceRefresh == true { options = [.forceRefresh] }
    self.kf.setImage(with: imageURL, placeholder: placeholder, options: options)
  }
  
  /// 设置图片
  ///
  /// - Parameters:
  ///   - url: 要设置的图片地址，类型包括URL，可以转化为URL的String
  ///   - placeholder: 占位图，可以是UIImage，也可以是通过能通过UIImage(named:)生成图片的本地图片名
  ///   - isForceRefresh: 是否强制刷新
  ///   - completionHandler: 设置图片后的回调
  func setImage(with url: Any?, placeholder: Any? = nil, isForceRefresh: Bool = false, completionHandler: @escaping (UIImage?) -> Void) {
    
    let placeholder: UIImage? = self.prepare(with: placeholder)
    let imageURL: URL? = self.prepare(with: url)
    
    var options: KingfisherOptionsInfo?
    if isForceRefresh == true { options = [.forceRefresh] }
    self.kf.setImage(with: imageURL, placeholder: placeholder, options: options) { (image, error, _, url) in
      
      completionHandler(image)
    }
  }
  
}

public extension UIButton {
  
  /// 设置图片
  ///
  /// - Parameters:
  ///   - url: 要设置的图片地址，类型包括URL，可以转化为URL的String
  ///   - placeholder: 占位图，可以是UIImage，也可以是通过能通过UIImage(named:)生成图片的本地图片名
  ///   - state: 图片显示时所对应的UIControl.State
  func setImage(with url: Any?, placeholder: Any? = nil, for state: UIControl.State = .normal) {
    
    let placeholder: UIImage? = self.prepare(with: placeholder)
    let imageURL: URL? = self.prepare(with: url)
    
    self.kf.setImage(with: imageURL, for: state, placeholder: placeholder)
  }
  
}

// MARK: - Utility
private extension UIView {
  
  func prepare(with url: Any?) -> URL? {
    
    if let urlString = url as? String { return URL(string: urlString) }
    if let url = url as? URL { return url }
    
    return nil
  }
  
  func prepare(with placeholder: Any?) -> UIImage? {
    
    if let placeholder = placeholder as? UIImage { return placeholder }
    if let placeholder = placeholder as? String { return UIImage(named: placeholder) }
    return nil
  }
  
}

public extension UIImage {
  
  func draw(_ size: CGSize,
               mode: ImageKit.DrawMode = .default) -> UIImage? {
    
    var drawedSize = size
    let imageSize = self.size
    
    if drawedSize == .zero { drawedSize = UIScreen.main.bounds.size }
    var scale: CGFloat = 1
    
    switch mode {
      
    case .fill:
      
      let imageScale = imageSize.width / imageSize.height
      let drawedScale = drawedSize.width / drawedSize.height
      
      scale = imageScale > drawedScale
        ? drawedSize.height / imageSize.height
        : drawedSize.width / imageSize.width
      
    case .fit:
      
      let imageScale = imageSize.width / imageSize.height
      let tailoredScale = drawedSize.width / drawedSize.height
      
      scale = imageScale > tailoredScale
        ? drawedSize.width / imageSize.width
        : drawedSize.height / imageSize.height
      
    default: break
      
    }
    drawedSize = CGSize(width: Int(imageSize.width * scale),
                        height: Int(imageSize.height * scale))
    
    let tailoredRect = CGRect(origin: CGPoint.zero,
                              size: drawedSize)
    
    UIGraphicsBeginImageContextWithOptions(drawedSize, true, 0)
    self.draw(in: tailoredRect)
    let tailoredImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return tailoredImage
  }
  
}
