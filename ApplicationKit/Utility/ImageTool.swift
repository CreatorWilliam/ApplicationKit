//
//  ImageTool.swift
//  ComponentKit
//
//  Created by William Lee on 19/12/17.
//  Copyright © 2018 William Lee. All rights reserved.
//

import UIKit

public struct ImageTool {
  
  public static func gaussianBlur(for image: UIImage, with radius: CGFloat, handle: @escaping (UIImage) -> Void) {
    
    //使用高斯模糊滤镜
    DispatchQueue.global().async(execute: {
      
      guard let filter = CIFilter(name: "CIGaussianBlur") else { return }
      let inputImage = CIImage(image: image)
      filter.setValue(inputImage, forKey: kCIInputImageKey)
      //设置模糊半径值（越大越模糊）
      filter.setValue(radius, forKey: kCIInputRadiusKey)
      guard let outputCIImage = filter.outputImage else { return }
      let rect = CGRect(origin: CGPoint.zero, size: image.size)
      
      let context = CIContext()
      guard let cgImage = context.createCGImage(outputCIImage, from: rect) else { return }
      
      DispatchQueue.main.async(execute: {
        
        handle(UIImage(cgImage: cgImage))
      })
      
    })
    
  }
  
  /// 矩形纯色图片
  ///
  /// - Parameters:
  ///   - color: 图片颜色
  ///   - size: 图片大小
  /// - Returns: 图片
  public static func rectangle(with color: UIColor,
                       and size: CGSize = CGSize(width: 1, height: 1)) -> UIImage? {
    
    let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
    
    UIGraphicsBeginImageContextWithOptions(rect.size, true, 0)
    let context = UIGraphicsGetCurrentContext()
    
    context?.setFillColor(color.cgColor)
    context?.fill(rect)
    let image = UIGraphicsGetImageFromCurrentImageContext()
    
    UIGraphicsEndImageContext()
    
    return image
  }
  
  /// 圆形纯色图片
  ///
  /// - Parameters:
  ///   - color: 图片颜色
  ///   - radius: 半径
  /// - Returns: 图片
  public static func roundness(with color: UIColor,
                          and radius: Int) -> UIImage? {
    
    let rect = CGRect(x: 0, y: 0, width: radius * 2, height: radius * 2)
    
    UIGraphicsBeginImageContextWithOptions(rect.size, true, 0)
    let context = UIGraphicsGetCurrentContext()
    context?.addEllipse(in: rect)
    context?.setFillColor(color.cgColor)
    context?.fillPath()
    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return image
  }
  
  /// 带下划线的图片
  ///
  /// - Parameters:
  ///   - color: 下划线颜色
  ///   - backgroundColor: 背景颜色
  ///   - rect: 图片大小
  public static func underline(with color: UIColor,
                          background backgroundColor: UIColor = UIColor.white,
                          and rect: CGRect) -> UIImage? {
    
    UIGraphicsBeginImageContext(rect.size)
    let context = UIGraphicsGetCurrentContext()
    
    context?.setFillColor(backgroundColor.cgColor)
    context?.fill(rect)
    
    context?.setFillColor(color.cgColor)
    let underlineRect = CGRect(x: 0, y: rect.size.height - 2, width: rect.size.width, height: 2)
    context?.fill(underlineRect)
    
    let underlineImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return underlineImage
  }
  
  /// 绘制省略号
  ///
  /// - Parameters:
  ///   - color: 省略号颜色
  ///   - backgroundColor: 背景色
  /// - Returns: 图片
  public static func suspension(with color: UIColor, background backgroundColor: UIColor = UIColor.clear) -> UIImage? {
    
    UIGraphicsBeginImageContext(CGSize(width: 7, height: 1))
    let context = UIGraphicsGetCurrentContext()
    
    context?.setFillColor(backgroundColor.cgColor)
    context?.fill(CGRect(x: 0, y: 0, width: 7, height: 1))
    
    context?.setFillColor(color.cgColor)
    
    context?.fill(CGRect(x: 1, y: 0, width: 1, height: 1))
    context?.fill(CGRect(x: 3, y: 0, width: 1, height: 1))
    context?.fill(CGRect(x: 5, y: 0, width: 1, height: 1))
    
    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return image
  }
  
}


// MARK: - Draw
public extension ImageTool {
  
  enum DrawMode {
    
    case `default`
    case fill
    case fit
    
  }
  
  static func draw(_ image: UIImage, _ size: CGSize = UIScreen.main.bounds.size,
                          mode: DrawMode = .default) -> UIImage? {
    
    var drawedSize = size
    let imageSize = image.size
    
    if drawedSize.equalTo(CGSize.zero) {
      
      drawedSize = UIScreen.main.bounds.size
    }
    var scale: CGFloat
    
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
      
    default:
      
      scale = drawedSize.width / imageSize.width
      break
      
    }
    drawedSize = CGSize(width: Int(imageSize.width * scale),
                        height: Int(imageSize.height * scale))
    
    let tailoredRect = CGRect(origin: CGPoint.zero,
                              size: drawedSize)
    
    UIGraphicsBeginImageContextWithOptions(drawedSize, true, 0)
    image.draw(in: tailoredRect)
    let tailoredImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return tailoredImage
  }
  
}
