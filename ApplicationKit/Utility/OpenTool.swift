//
//  OpenTool.swift
//  ComponentKit
//
//  Created by  William Lee on 06/03/2018.
//  Copyright © 2018 William Lee. All rights reserved.
//

import UIKit

public struct OpenTool {
  
  public static func openInSafari(with url: URL) {
    
    DispatchQueue.main.async {
      
      let alertController = UIAlertController(title: "提示", message: "使用Safari打开", preferredStyle: .alert)
      
      let cancelAction = UIAlertAction(title: "取消", style: .cancel) { (actrion) in
        
        
      }
      
      let openAction = UIAlertAction(title: "打开", style: .default) { (action) in
        
        UIApplication.shared.openURL(url)
      }
      
      alertController.addAction(cancelAction)
      alertController.addAction(openAction)
      
      Presenter.present(alertController, animated: true)
      
    }
    
  }
  
}
