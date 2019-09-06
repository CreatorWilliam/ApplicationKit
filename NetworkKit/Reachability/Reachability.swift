//
//  Reachability.swift
//  NetworkKit
//
//  Created by William Lee on 2018/8/9.
//  Copyright © 2018 William Lee. All rights reserved.
//

import SystemConfiguration
import Foundation

public class Reachability: NSObject {
  
  public private(set) static var shared: Reachability?
  
  private var reachability: SCNetworkReachability
  
  public private(set) var status: Status = .not
  
  public var queue: DispatchQueue = DispatchQueue.main
  public var monitorHandle: (_ status: Status) -> Void = { status in
    
    switch status {
      
    case .wifi:
      
      if Network.isDebug {
        
        print("WiFi")
      }
      
    case .wwan:
      
      if Network.isDebug {
        
        print("WWAN")
      }
      
    default:
      
      if Network.isDebug {
        
        print("No Network")
      }
      
      break
    }
  }
  
  public init?(host: String) {
    
    guard let host = URL(string: host)?.host else { return nil }
    guard let reachability = SCNetworkReachabilityCreateWithName(nil, host) else { return nil }
    self.reachability = reachability
    
    super.init()
    Reachability.shared = self
  }
  
  deinit {
    
    stopMonitor()
  }
  
}

// MARK: - Public
public extension Reachability {
  
  /// 网络状态
  enum Status {
    
    /// 无网络
    case not
    /// WiFi网络
    case wifi
    /// 蜂窝网络
    case wwan
  }
  
  /// 网络状态变更后，通知中UserInfo中用此Key获取网络状态, value为Reachability.Status类型
  static let StatusKey: String = "NetworkReachabilityStatusKey"
  // MARK: - 网络状态变更后的发出通知
  static let statusChangedNotification = Notification.Name("NetworkReachabilityStatusChangedNotification")
  
  /// 启动网络监控
  ///
  /// - Returns: 是否成功启动
  @discardableResult
  func startMonitor() -> Bool {
    
    var context = SCNetworkReachabilityContext(version: 0, info: nil, retain: nil, release: nil, copyDescription: nil)
    context.info = Unmanaged.passUnretained(self).toOpaque()
    
    let canCallBack = SCNetworkReachabilitySetCallback(reachability, Reachability.callback, &context)
    let canDispatch = SCNetworkReachabilitySetDispatchQueue(reachability, queue)
    
    return canCallBack && canDispatch
    
  }
  
  
  /// 停止网络监控
  func stopMonitor() {
    
    SCNetworkReachabilitySetCallback(reachability, nil, nil)
    SCNetworkReachabilitySetDispatchQueue(reachability, nil)
  }
  
}

// MARK: - Utility
private extension Reachability {
  
  static let callback: SystemConfiguration.SCNetworkReachabilityCallBack = { target, flags, info in
    
    let reachability = Unmanaged<Reachability>.fromOpaque(info!).takeUnretainedValue()
    
    //执行监听回调
    let status = reachability.query(flags)
    
    guard reachability.status != status else { return }
    
    reachability.status = status
    reachability.monitorHandle(status)
    
    NotificationCenter.default.post(name: Reachability.statusChangedNotification,
                                    object: nil,
                                    userInfo: [Reachability.StatusKey: reachability.status])
  }
  
  /// 获取网络状态
  ///
  /// - Parameter flags: 网络标记
  /// - Returns: 网络状态
  func query(_ flags: SCNetworkReachabilityFlags) -> Status {
    
    guard flags.contains(.reachable) else { return .not }
    
    var status: Status = .not
    
    if !flags.contains(.connectionRequired) {
      
      status = .wifi
    }
    
    if flags.contains(.connectionOnDemand) || flags.contains(.connectionOnTraffic) {
      
      if !flags.contains(.interventionRequired) {
        
        status = .wifi
      }
    }
    
    #if os(iOS)
    if flags.contains(.isWWAN) {
      
      status = .wwan
    }
    #endif
    
    return status
  }
  
}
