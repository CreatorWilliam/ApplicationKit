//
//  JPush.swift
//  JPushKit
//
//  Created by William Lee on 2018/8/16.
//  Copyright © 2018 William Lee. All rights reserved.
//

import Foundation
import UserNotifications

public class JPush: NSObject {
  
  private static let shared = JPush()
  private override init() {
    super.init()
  }
  
}

// MARK: - Setup
public extension JPush {
  
  /// 注册极光推送
  ///
  /// - Parameters:
  ///   - appKey: 极光后台获取
  ///   - options: 应用启动时的参数
  class func register(appKey: String, with launchOptions: [UIApplicationLaunchOptionsKey: Any]?) {
    
    let entity = JPUSHRegisterEntity()
    entity.types = Int(JPAuthorizationOptions.alert.rawValue | JPAuthorizationOptions.badge.rawValue | JPAuthorizationOptions.sound.rawValue)
    
    JPUSHService.register(forRemoteNotificationConfig: entity, delegate: JPush.shared)
    
    // Required
    // init Push
    // notice: 2.1.5版本的SDK新增的注册 法，改成可上报IDFA，如果没有使 IDFA直接传nilet
    JPUSHService.setup(withOption: launchOptions, appKey: appKey, channel: nil, apsForProduction: false, advertisingIdentifier: nil)
    
  }
  
  /// 注册设备
  ///
  /// - Parameter deviceToken: 设备Token
  class func register(_ deviceToken: Data) {
    
    JPUSHService.registerDeviceToken(deviceToken)
  }
  
  class func setAlias(_ alias: String?) {
    
    guard let alias = alias else { return }
    JPUSHService.setAlias(alias, completion: { (code, alias, seq) in
      
    }, seq: 1)
    
  }
  
  class func removeAlias() {
    
    JPUSHService.deleteAlias({ (code, alias, seq) in
      
    }, seq: 2)
  }
  
  class func getAlias(_ handle: (String?) -> Void) {

    JPUSHService.getAlias({ (code, alias, seq) in
      
    }, seq: 3)
  }
  
  /// 处理通知
  ///
  /// - Parameter userInfo: 通知内容信息
  class func handleRemoteNotification(_ userInfo: [AnyHashable: Any]) {
    
    JPUSHService.handleRemoteNotification(userInfo)
  }
  
  /// 开启远程通知
  class func open() {
    
    UIApplication.shared.registerForRemoteNotifications()
  }
  
  /// 关闭远程通知
  class func close() {
    
    UIApplication.shared.unregisterForRemoteNotifications()
  }
  
}

// MARK: - JPUSHRegisterDelegate
extension JPush: JPUSHRegisterDelegate {

  @available(iOS 10.0, *)
  public func jpushNotificationCenter(_ center: UNUserNotificationCenter!, didReceive response: UNNotificationResponse!, withCompletionHandler completionHandler: (() -> Void)!) {

    let userInfo = response.notification.request.content.userInfo
    if response.notification.request.trigger?.isKind(of: UNPushNotificationTrigger.self) ?? false {
      JPUSHService.handleRemoteNotification(userInfo)
    }
    completionHandler()
  }

  @available(iOS 10.0, *)
  public func jpushNotificationCenter(_ center: UNUserNotificationCenter!, willPresent notification: UNNotification!, withCompletionHandler completionHandler: ((Int) -> Void)!) {

    // Required
    let userInfo = notification.request.content.userInfo
    if notification.request.trigger?.isKind(of: UNPushNotificationTrigger.self) ?? false {

      JPUSHService.handleRemoteNotification(userInfo)
    }

    completionHandler(Int(UNNotificationPresentationOptions.alert.rawValue)) // 需要执行这个方法，选择是否提醒用户，有Badge、Sound、Alert三种类型可以选择设置
  }

}









