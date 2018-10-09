//
//  ImageKit.swift
//  ImageKit
//
//  Created by William Lee on 2018/10/9.
//  Copyright © 2018 William Lee. All rights reserved.
//

import UIKit

public extension UIImageView {
  
  func setImage(url: Any?, placeholder: String? = nil, ignore: Bool = false) {
    
    var placeholderImage: UIImage?
    if let placeholder = placeholder { placeholderImage = UIImage(named: placeholder) }
    
    var imageURL: URL?
    // String to URL
    if let urlString = url as? String { imageURL = URL(string: urlString) }
    // Set URL
    else if let url = url as? URL { imageURL = url }
    else { }
    
    var options: KingfisherOptionsInfo?
    if ignore == true { options = [.forceRefresh] }
    self.kf.setImage(with: imageURL, placeholder: placeholderImage, options: options)
    
  }
  
  func setImage(url: Any?, placeholder: String? = nil, ignore: Bool = false, completionHandler: @escaping (UIImage?) -> Void) {
    
    var placeholderImage: UIImage?
    if let placeholder = placeholder { placeholderImage = UIImage(named: placeholder) }
    
    var imageURL: URL?
    // String to URL
    if let urlString = url as? String { imageURL = URL(string: urlString) }
      // Set URL
    else if let url = url as? URL { imageURL = url }
    else { }
    
    var options: KingfisherOptionsInfo?
    if ignore == true { options = [.forceRefresh] }
    self.kf.setImage(with: imageURL, placeholder: placeholderImage, options: options) { (image, error, _, url) in
      
      completionHandler(image)
    }
  }
  
}

public extension UIButton {
  
  func setImage(url: Any?, placeholder: String? = nil, for state: UIControl.State = .normal) {
    
    var image: UIImage?
    if let placeholder = placeholder { image = UIImage(named: placeholder) }
    
    var imageURL: URL?
    // String to URL
    if let urlString = url as? String { imageURL = URL(string: urlString) }
      // Set URL
    else if let url = url as? URL { imageURL = url }
    else { }
    
    self.kf.setImage(with: imageURL, for: state, placeholder: image)
  }
  
}

