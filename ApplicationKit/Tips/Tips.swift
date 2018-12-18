//
//  Tips.swift
//  ComponentKit
//
//  Created by William Lee on 2018/12/10.
//  Copyright © 2018 William Lee. All rights reserved.
//

import Foundation

/// 根据判决显示对应的提示信息，便于集中管理提示信息
public struct Tips {
  
  public static func developing() {
    
    Presenter.currentPresentedController?.hud.showMessage(message: "开发中...")
  }
  
}

// MARK: - General
public extension Tips {
  
  static func judg(account: String?) -> Bool {
    
    guard (account ?? "").check(.mobil) else {
      
      Presenter.currentPresentedController?.hud.showMessage(message: "请输入正确的手机号码，复制粘贴请注意空格！")
      return false
    }
    return true
  }
  
  static func judg(password: String?) -> Bool {
    
    guard (password?.count ?? 0) > 0 else {
      
      Presenter.currentPresentedController?.hud.showMessage(message: "请输入密码")
      return false
    }
    return true
  }
  
  static func judg(verifyCode: String?) -> Bool {
    
    guard (verifyCode?.count ?? 0) > 0  else {
      
      Presenter.currentPresentedController?.hud.showMessage(message: "请输入验证码")
      return false
    }
    return true
  }
  
  static func judg(invitationCode: String?) -> Bool {
    
    guard (invitationCode?.count ?? 0) > 0 else {
      
      Presenter.currentPresentedController?.hud.showMessage(message: "请输入邀请码")
      return false
    }
    return true
  }
}
