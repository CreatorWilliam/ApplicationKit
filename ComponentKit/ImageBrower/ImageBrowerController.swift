//
//  ImageBrowerController.swift
//  ComponentKit
//
//  Created by William Lee on 18/12/17.
//  Copyright © 2017年 William Lee. All rights reserved.
//

import ApplicationKit
import UIKit

public class ImageBrowerController: UIViewController {
  
  private let browerView = ImageBrowerView()
  
  private var images: [Any] = []
  private var initIndex: Int = 0
  
  override public var prefersStatusBarHidden: Bool { return true }

  override public func viewDidLoad() {
    super.viewDidLoad()
    
    self.setupUI()
  }
  
  override public func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    self.browerView.update(index: self.initIndex)
  }
  
}

// MARK: - Public
public extension ImageBrowerController {
  
  class func open(with images: [Any], at index: Int = 0) {
    
    let controller = ImageBrowerController()
    controller.initIndex = index
    controller.images = images
    Presenter.present(controller, animated: false)
  }
  
}

// MARK: - Setup
private extension ImageBrowerController {
  
  func setupUI() {
    
    self.view.backgroundColor = UIColor.black
    
    self.browerView.update(images: self.images)
    self.view.addSubview(self.browerView)
    self.browerView.layout.add { (make) in
      make.top().bottom().leading().trailing().equal(self.view)
    }
    
  }
  
}
