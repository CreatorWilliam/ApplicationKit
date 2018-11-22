//
//  ImagePicker.swift
//  ComponentKit
//
//  Created by William Lee on 23/12/17.
//  Copyright © 2018 William Lee. All rights reserved.
//

import UIKit
import Photos

public class ImagePicker: NSObject {
  
  private static let shared = ImagePicker()
  private let imagePicker = UIImagePickerController()
  private var isOrigin: Bool = false
  private var completeHandle: CompleteHandle?
  
  public override init() {
    super.init()
    
    self.imagePicker.delegate = self
  }
  
}

// MARK: - Public
public extension ImagePicker {
  
  typealias CompleteHandle = ([PHAsset], [UIImage]) -> Void
  
  class func openCamera(isOrigin: Bool = false, limited count: Int = 1,
                        withHandle handle: @escaping CompleteHandle) {
    
    ImagePicker.shared.completeHandle = handle
    ImagePicker.shared.isOrigin = isOrigin
    if UIImagePickerController.isSourceTypeAvailable(.camera) {
      
      ImagePicker.shared.imagePicker.sourceType = .camera
      Presenter.present(ImagePicker.shared.imagePicker, animated: true)
    }
  }
  
  class func openPhotoLibrary(isOrigin: Bool = false, limited count: Int = 1,
                              withHandle handle: @escaping CompleteHandle) {
    
    ImagePicker.shared.completeHandle = handle
    ImagePicker.shared.isOrigin = isOrigin
    // 是否可以打开相册
    if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
      
      if count < 2 {
        
        ImagePicker.shared.imagePicker.sourceType = .photoLibrary
        Presenter.present(ImagePicker.shared.imagePicker, animated: true)
        return
      }
      ImagePickerAlbumViewController.openPicker(withLimited: count, completion: { (asset, images) in
        
        ImagePicker.shared.completeHandle?([], images)
        ImagePicker.shared.completeHandle = nil
      })
    }
  }
  
  class func open(isOrigin: Bool = false, limited count: Int = 1,
                  withHandle handle: @escaping CompleteHandle) {
    
//    ImagePicker.shared.completeHandle = handle
//    ImagePicker.shared.isOrigin = isOrigin
    
    let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
    
    alertController.addAction(UIAlertAction(title: "取消", style: .cancel, handler: { (action) in
      
    }))
    
    // 是否可以打开相机
    if UIImagePickerController.isSourceTypeAvailable(.camera) {
      
      alertController.addAction(UIAlertAction(title: "拍照", style: .default, handler: { (action) in
        ImagePicker.openCamera(withHandle: handle)
//        ImagePicker.shared.imagePicker.sourceType = .camera
//        Presenter.present(ImagePicker.shared.imagePicker, animated: true)
      }))
    }
    
    // 是否可以打开相册
    if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
      
      alertController.addAction(UIAlertAction(title: "选择图片", style: .default, handler: { (action) in
        ImagePicker.openPhotoLibrary(withHandle: handle)
//        if count < 2 {
//
//          ImagePicker.shared.imagePicker.sourceType = .photoLibrary
//          Presenter.present(ImagePicker.shared.imagePicker, animated: true)
//          return
//        }
//        ImagePickerAlbumViewController.openPicker(withLimited: count, completion: { (asset, images) in
//
//          ImagePicker.shared.completeHandle?([], images)
//          ImagePicker.shared.completeHandle = nil
//        })
        
      }))
    }
    
    DispatchQueue.main.async {
      
      Presenter.present(alertController, animated: true)
      
    }
    
  }
  
}

// MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate
extension ImagePicker: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  
  public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    // Local variable inserted by Swift 4.2 migrator.
    let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)
    
    
    defer {
      
      // 因为是全局的，用完一次就可以清除回调
      picker.dismiss(animated: true)
      
    }
    
    // 获取选择的图片
    guard let originImage = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as? UIImage else { return }
    
    /// 如果需要原图，则直接返回原图
    if self.isOrigin {
      
      DispatchQueue.main.async {
        
        self.completeHandle?([], [originImage])
        self.completeHandle = nil
      }
      return
    }
    
    /// 默认是重绘后的图片
    if let image = ImageTool.draw(originImage) {
      
      DispatchQueue.main.async {
        
        self.completeHandle?([], [image])
        self.completeHandle = nil
      }
      return
    }
    
    
  }
  
  public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    
    defer {
      
      // 因为是全局的，用完一次就可以清除回调
      picker.dismiss(animated: true)
      
    }
    
    self.completeHandle = nil
    
  }
  
}













// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
  return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
  return input.rawValue
}
