//
//  ImageKit.swift
//  ImageKit
//
//  Created by William Lee on 2018/10/9.
//  Copyright © 2018 William Lee. All rights reserved.
//

import UIKit

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
  func setImage(with url: Any?, placeholder: String? = nil, for state: UIControl.State = .normal) {
    
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
