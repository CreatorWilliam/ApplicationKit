//
//  NavigationView.swift
//  ComponentKit
//
//  Created by William Lee on 20/12/17.
//  Copyright © 2018 William Lee. All rights reserved.
//

import UIKit
import LayoutKit

public class NavigationView: UIView {
  
  /// 默认导航栏标题颜色
  public static var defaultTitleColor: UIColor = .black
  /// 默认导航栏标题字体
  public static var defaultTitleFont: UIFont = UIFont.boldSystemFont(ofSize: 18)
  /// 默认导航栏背景色
  public static var defaultBackgroundColor: UIColor = .white
  /// 默认导航栏背景图，接受图片名String，图片UIImage
  public static var defaultBackgroundImage: Any? = nil
  /// 默认导航栏返回按钮图片
  public static var defaultBackImage: String?
  /// 默认导航栏返回按钮标题
  public static var defaultBackTitle: String = "返回"
  
  /// 导航栏标题
  public private(set) var titleLabel: UILabel = UILabel()
  /// 导航栏背景
  public private(set) var backgroundView: UIImageView = UIImageView()
  
  /// 导航栏内容基础高度
  private var navigationBaseHeight: CGFloat = 44
  
  /// 内容视图，承载左右两侧的操作按钮
  fileprivate var contentView = UIToolbar()
  /// 左侧操作集
  fileprivate var leftItems: [UIBarButtonItem] = []
  /// 右侧操作集
  fileprivate var rightItems: [UIBarButtonItem] = []
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    self.backgroundColor = .clear
    
    let screenWidth = UIScreen.main.bounds.width
    let statusBarHeight = UIApplication.shared.statusBarFrame.height
    self.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: self.navigationBaseHeight + statusBarHeight)
    
    //BackgroundView
    self.backgroundView.contentMode = .scaleAspectFill
    self.backgroundView.clipsToBounds = true
    self.addSubview(self.backgroundView)
    self.backgroundView.layout.add { (make) in
      make.top().bottom().leading().trailing().equal(self)
    }
    
    // ContentView
    self.contentView.frame = CGRect(x: 0, y: statusBarHeight, width: screenWidth, height: 44)
    self.contentView.setBackgroundImage(UIImage(), forToolbarPosition: UIBarPosition.any, barMetrics: UIBarMetrics.default)
    self.contentView.setShadowImage(UIImage(), forToolbarPosition: UIBarPosition.any)
    self.contentView.backgroundColor = .clear
    self.addSubview(self.contentView)
    
    //TitleView
    self.titleLabel.textAlignment = .center
    self.titleLabel.font = UIFont.systemFont(ofSize: 16)
    self.titleLabel.textColor = .white
    self.contentView.addSubview(self.titleLabel)
    self.titleLabel.layout.add { (make) in
      make.top().bottom().equal(self.contentView)
      make.leading(40).trailing(-40).equal(self.contentView)
    }
    
    NotificationCenter.default.addObserver(self, selector: #selector(recieveStatusDidChange), name: UIApplication.didChangeStatusBarFrameNotification, object: nil)
  }
  
  required public init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  deinit {
    
    NotificationCenter.default.removeObserver(self)
  }
  
  public override func layoutSubviews() {
    super.layoutSubviews()
    
    let width = self.superview?.frame.width ?? 0 //UIScreen.main.bounds.width
    let statusBarHeight = UIApplication.shared.statusBarFrame.height
    self.frame = CGRect(x: 0, y: 0, width: width, height: self.navigationBaseHeight + statusBarHeight)
    self.contentView.frame = CGRect(x: 0, y: statusBarHeight, width: width, height: 44)
  }
  
  private func updateBackground(image: Any?, color: UIColor) {
    
    self.backgroundView.backgroundColor = color
    
    if let imageName = image as? String {
      
      self.backgroundView.image = UIImage(named: imageName)
      
    } else if let image = image as? UIImage {
      
      self.backgroundView.image = image
      
    } else {
      
      self.backgroundView.image = nil
    }
  }
  
}

// MARK: - Appearance
public extension NavigationView {
  
  /// 设置导航栏样式
  ///
  /// - Parameters:
  ///   - title: 标题
  ///   - titleColor: 标题颜色
  ///   - titleFont: 标题字体大小
  ///   - backgroundImage: 背景图片
  ///   - backgroundColor: 背景颜色
  func setup(title: String? = nil,
             titleColor: UIColor = NavigationView.defaultTitleColor,
             titleFont: UIFont = NavigationView.defaultTitleFont,
             backgroundImage: Any? = NavigationView.defaultBackgroundImage,
             backgroundColor: UIColor = NavigationView.defaultBackgroundColor) {
    
    self.isHidden = false
    
    //Title
    self.titleLabel.text = title
    self.titleLabel.textColor = titleColor
    self.titleLabel.font = titleFont
    
    //Background
    self.updateBackground(image: backgroundImage, color: backgroundColor)
    
  }
  
  /// 设置自定义导航栏的自定义标题视图
  ///
  /// - Parameter view: 自定义的标题视图
  func setupCustomTitleView(_ view: UIView,
                            backgroundImage: Any? = NavigationView.defaultBackgroundImage,
                            backgroundColor: UIColor = NavigationView.defaultBackgroundColor) {
    
    self.isHidden = false
    
    //添加新的标题视图
    self.addSubview(view)
    view.layout.add { (make) in
      
      make.centerY().equal(self.contentView)
    }
    
    //Background
    self.updateBackground(image: backgroundImage, color: backgroundColor)
    
  }
  
  /// 设置导航栏高度，不需要计算状态栏高度
  ///
  /// - Parameter height: 导航栏内容高度
  func setContentHeight(_ height: CGFloat) {
    
    self.navigationBaseHeight = height
    self.setNeedsLayout()
  }
  
}

// MARK: - Item Handle
public extension NavigationView {
  
  /// 显示自定义导航栏返回按钮
  ///
  /// - Parameter image: 返回按钮图标
  @discardableResult
  func showBack(image name: String? = NavigationView.defaultBackImage) -> UIBarButtonItem {
  

    
    var item: UIBarButtonItem
    if let name = name {
      
      item = UIBarButtonItem(image: UIImage(named: name)?.withRenderingMode(.alwaysOriginal),
                             style: UIBarButtonItem.Style.plain, target: self,
                             action: #selector(clickNavigationBack))
      
    } else {
      
      item = UIBarButtonItem(title: NavigationView.defaultBackTitle,
                             style: UIBarButtonItem.Style.plain, target: self,
                             action: #selector(clickNavigationBack))
    }
    
    item.tintColor = self.titleLabel.textColor
    self.leftItems.insert(item, at: 0)
    let flexibleItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
    self.contentView.items = (self.leftItems + [flexibleItem] + self.rightItems)

    return item
  }
  
  /// 添加左侧导航栏Item
  ///
  /// - Parameters:
  ///   - image: Item的图标
  ///   - target: 执行点击事件的对象
  ///   - action: 点击事件
  @discardableResult
  func addLeft(image name: String, target: Any? = nil, action: Selector? = nil) -> UIBarButtonItem {
    
    let item = UIBarButtonItem(image: UIImage(named: name)?.withRenderingMode(.alwaysOriginal), style: UIBarButtonItem.Style.plain, target: target, action: action)
    return self.addLeft(item)
  }
  
  /// 添加左侧导航栏Item
  ///
  /// - Parameters:
  ///   - title: Item的标题
  ///   - target: 执行点击事件的对象
  ///   - action: 点击事件
  @discardableResult
  func addLeft(title: String, target: Any?, action: Selector?) -> UIBarButtonItem {
    
    let item = UIBarButtonItem(title: title, style: UIBarButtonItem.Style.plain, target: target, action: action)
    return self.addLeft(item)
  }
  
  /// 添加左侧导航栏Item
  ///
  /// - Parameters:
  ///   - Item: Item
  @discardableResult
  func addLeft(_ item: UIBarButtonItem) -> UIBarButtonItem {
    
    self.leftItems.append(item)
    item.tintColor = self.titleLabel.textColor
    let flexibleItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
    self.contentView.items = (self.leftItems + [flexibleItem] + self.rightItems)
    return item
  }
  
  /// 移除左侧所有Items
  func removeAllLeftItems() {
    
    self.leftItems.removeAll()
    let flexibleItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
    self.contentView.items = (self.leftItems + [flexibleItem] + self.rightItems)
  }
  
  /// 添加右侧导航栏Item
  ///
  /// - Parameters:
  ///   - imageNmae: Item的图标
  ///   - target: 执行点击事件的对象
  ///   - action: 点击事件
  @discardableResult
  func addRight(image name: String, target: Any?, action: Selector?) -> UIBarButtonItem {
    
    let item = UIBarButtonItem(image: UIImage(named: name)?.withRenderingMode(.alwaysOriginal), style: UIBarButtonItem.Style.plain, target: target, action: action)
    return self.addRight(item)
  }
  
  /// 添加右侧导航栏Item
  ///
  /// - Parameters:
  ///   - title: Item的标题
  ///   - target: 执行点击事件的对象
  ///   - action: 点击事件
  @discardableResult
  func addRight(title: String, target: Any?, action: Selector?) -> UIBarButtonItem {
    
    let item = UIBarButtonItem(title: title, style: UIBarButtonItem.Style.plain, target: target, action: action)
    return self.addRight(item)
  }
  
  /// 添加右侧导航栏Item
  ///
  /// - Parameters:
  ///   - image: Item图标
  ///   - title: Item标题
  /// - Returns: Item
  @discardableResult
  func addRight(_ item: UIBarButtonItem) -> UIBarButtonItem {
    
    self.rightItems.insert(item, at: 0)
    item.tintColor = self.titleLabel.textColor
    let flexibleItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
    self.contentView.items = (self.leftItems + [flexibleItem] + self.rightItems)
    return item
  }
  
  /// 移除右侧所有Items
  func removeAllRightItems() {
    
    self.rightItems.removeAll()
    let flexibleItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
    self.contentView.items = (self.leftItems + [flexibleItem] + self.rightItems)
  }
  
}

// MARK: - Action
private extension NavigationView {
  
  @objc func clickNavigationBack(_ sender: UIBarButtonItem) {
    
    if let _ = Presenter.pop() { return }
    Presenter.dismiss()
  }
  
}

// MARK: - Notification
private extension NavigationView {
  
  @objc func recieveStatusDidChange(_ notification: Notification) {
    
    setNeedsLayout()
  }
  
}

// MARK: - Navigation
public extension UIViewController {
  
  private struct NavigationExtensionKey {
    
    static var navigationViewKey: Void?
  }
  
  /// NavigaionBar
  var navigationView: NavigationView {
    
    if let temp = objc_getAssociatedObject(self, &NavigationExtensionKey.navigationViewKey) as? NavigationView { return temp }
    let temp = NavigationView()
    self.view.addSubview(temp)
    self.navigationController?.navigationBar.isHidden = true
    objc_setAssociatedObject(self, &NavigationExtensionKey.navigationViewKey, temp, .OBJC_ASSOCIATION_RETAIN)
    
    return temp
  }
}
