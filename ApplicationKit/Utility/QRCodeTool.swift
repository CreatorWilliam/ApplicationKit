//
//  QRCodeTool.swift
//  ComponentKit
//
//  Created by William Lee on 2018/11/13.
//  Copyright © 2018 William Lee. All rights reserved.
//

import UIKit

public struct QRCodeTool {
  
}

public extension QRCodeTool {
 
  static func image(for text: String) -> UIImage? {
    
    // 1、创建滤镜对象
    guard let filter = CIFilter(name: "CIQRCodeGenerator") else { return nil }
    // 恢复滤镜的默认属性
    filter.setDefaults()
    // 将字符串转换成 NSdata (虽然二维码本质上是字符串, 但是这里需要转换, 不转换就崩溃)
    let data = text.data(using: .utf8)
    // 设置过滤器的输入值, KVC赋值
    filter.setValue(data, forKey: "inputMessage")
    
    // 3、获得滤镜输出的图像，然后放大获取高清图片
    guard let outputImage = filter.outputImage?.transformed(by: CGAffineTransform(scaleX: 5, y: 5)) else { return nil }
    
    // - - - - - - - - - - - - - - - - 添加中间小图标 - - - - - - - - - - - - - - - -
    // TODO
    
    return UIImage(ciImage: outputImage)
  }
  
}
