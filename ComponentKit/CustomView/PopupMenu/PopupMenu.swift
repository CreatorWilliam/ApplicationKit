//
//  PopupMenu.swift
//  VideoModule
//
//  Created by Hiu on 2018/6/6.
//  Copyright © 2018年 Hiu. All rights reserved.
//

import ApplicationKit
import UIKit

public protocol PopupMenuDelegate: class {
  
  func popupMenu(_ popupMenu: PopupMenu, didSelectAt index: Int)
  
  func popupMenuWillDisappear()
  
  func popupMenuDidDisappear()
  
  func popupMenuWillAppear()
  
  func popupMenuDidAppear()
}

extension PopupMenuDelegate {
  
  func popupMenuWillDisappear() { }
  
  func popupMenuDidDisappear() { }
  
  func popupMenuWillAppear() { }
  
  func popupMenuDidAppear() { }
}

open class PopupMenu: UIView {
  
  /// 箭头方向优先级,当控件超出屏幕时会自动调整成反方向
  public enum Direction {
    
    case top
    case bottom
    case left
    case right
    case none
  }
  
  public enum Style {
    
    case white //Default
    case dark
  }
  
  public var menuWidth: CGFloat = 100
  /// 默认的选中的索引
  public var defaultSelectedIndex: Int?
  /// 圆角半径 Default is 5.0
  public var cornerRadius: CGFloat = 5.0
  
  /// 自定义圆角 Default is UIRectCorner.allCorners,当自动调整方向时corner会自动转换至镜像方向
  public var rectCorner: UIRectCorner = .allCorners
  
  /// 是否显示阴影 Default is true
  public var isShowShadow: Bool = true {
    
    didSet {
      
      self.layer.shadowOpacity = isShowShadow == true ? 0.5 : 0
      self.layer.shadowOffset = CGSize.init(width: 0, height: 0)
      self.layer.shadowRadius = isShowShadow == true ? 2.0 : 0
    }
  }
  
  /// 是否显示灰色覆盖层 Default is YES
  public var showMaskView: Bool = true {
    
    didSet {
      
      self.menuBackgroundView.backgroundColor = (showMaskView == true ? UIColor.black.withAlphaComponent(0.1) : UIColor.clear)
    }
  }
  
  /// 点击菜单外消失  Default is YES
  public var isDismissOnTouchOutside: Bool = true
  
  /// 设置字体，默认：UIFont.systemFont(ofSize: 15)
  public var font: UIFont = UIFont.systemFont(ofSize: 15)
  /// 设置文字颜色，默认：UIColor.black
  public var textColor: UIColor = .black
  /// 设置选中文字颜色 默认为：UIColor.bluek
  public var selectedTextColor: UIColor = .blue
  /// 文字对齐方式，默认左对齐
  public var textAlignment: NSTextAlignment = .left
  
  /// 设置偏移距离 (>= 0) Default is 0.0
  public var offset: CGFloat = 0.0
  
  /// 边框宽度 Default is 0.0, 设置边框需 > 0
  public var borderWidth: CGFloat = 0.0
  
  /// 边框颜色 Default is LightGrayColor, borderWidth <= 0 无效
  public var borderColor: UIColor = .lightGray
  
  /// 箭头宽度 Default is 15
  public var arrowWidth: CGFloat = 15
  
  /// 箭头高度 Default is 10
  public var arrowHeight: CGFloat = 10
  
  /// 箭头位置 Default is center, 只有箭头优先级是left/right/none时需要设置
  public var arrowOffset: CGFloat = 0
  
  public var isCornerChanged: Bool = false
  public var isChangeDirection: Bool = false
  public var separatorColor: UIColor?
  
  /// 箭头方向 Default is top
  public var arrowDirection: Direction = .top
  
  /// 箭头优先方向 Default is PopupMenuArrowDirection.top,当控件超出屏幕时会自动调整箭头位置
  public var directionPriority: Direction = .top
  
  /// 可见的最大行数 Default is 5;
  public var maxVisibleCount: Int = 5
  
  /// menu背景色 Default is WhiteColor
  public var backColor: UIColor = .white
  
  /// item的高度 Default is 44;
  public var itemHeight: CGFloat = 44 {
    
    didSet {
      
      self.tableView.rowHeight = self.itemHeight
      self.updateUI()
    }
  }
  
  /// 设置显示模式 Default is PopupMenuType.defaultWhite
  public var style: Style = .white {

    didSet {

      switch self.style {
      case .dark:

        self.textColor = .lightGray
        self.backColor = UIColor(red: 0.25, green: 0.27, blue: 0.29, alpha: 1)
        self.separatorColor = .lightGray

      default:

        self.textColor = .black
        self.backColor = .white
        self.separatorColor = .lightGray
      }
    }
  }
  
  
  /// 代理
  private weak var delegate: PopupMenuDelegate?
  /// 选中回调
  private var selectedHandle: SelectedHandle?
  
  private var menuBackgroundView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
  private var relyRect: CGRect = .zero
  private var minSpace: CGFloat = 10.0
  
  
  override open var frame: CGRect {
    
    didSet {
      
      if arrowDirection == .top {
        
        tableView.frame = CGRect.init(x: borderWidth, y: borderWidth + arrowHeight, width: frame.size.width - borderWidth * 2, height: frame.size.height - arrowHeight)
        
      } else if arrowDirection == .bottom {
        
        tableView.frame = CGRect.init(x: borderWidth, y: borderWidth , width: frame.size.width - borderWidth * 2, height: frame.size.height - arrowHeight)
        
      } else if arrowDirection == .left {
        
        tableView.frame = CGRect.init(x: borderWidth + arrowHeight, y: borderWidth, width: frame.size.width - borderWidth * 2 - arrowHeight, height: frame.size.height)
        
      } else if arrowDirection == .right {
        
        tableView.frame = CGRect.init(x: borderWidth, y: borderWidth , width: frame.size.width - borderWidth * 2 - arrowHeight, height: frame.size.height)
        
      } else if arrowDirection == .none {
        
        tableView.frame = CGRect.init(x: borderWidth, y: borderWidth , width: frame.size.width - borderWidth * 2 , height: frame.size.height)
      }
    }
  }
  
  
  private var items: [PopupMenuItem] = []
  private var point: CGPoint = .zero
  
  private let tableView = UITableView.init(frame: CGRect.zero, style: UITableView.Style.plain)
  
  public init(_ menus: [PopupMenuItem], delegate: PopupMenuDelegate) {
    self.init()
    
    self.items = menus
    self.delegate = delegate
  }
  
  public typealias SelectedHandle = (_ index: Int) -> Void
  public init(_ menus: [PopupMenuItem], selected handle: @escaping SelectedHandle) {
    self.init()
    
    self.items = menus
    self.selectedHandle = handle
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    self.style = .white
    self.menuBackgroundView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.1)
    self.menuBackgroundView.alpha = 0
    let tap = UITapGestureRecognizer(target: self, action: #selector(touchOutside))
    self.menuBackgroundView.addGestureRecognizer(tap)
    self.alpha = 0
    self.backgroundColor = UIColor.clear
    
    self.tableView.delegate = self
    self.tableView.dataSource = self
    self.tableView.showsVerticalScrollIndicator = false
    self.tableView.backgroundColor = .clear
    self.tableView.separatorStyle = .none
    self.tableView.tableFooterView = UIView()
    self.tableView.register(cells: [ReuseItem(PopupMenuCell.self)])
    self.addSubview(self.tableView)
  }
  
  required public init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override open func draw(_ rect: CGRect) {
    super.draw(rect)
    
    self.drawBezierPath(with: rect)
  }
}

// MARK: - Public
public extension PopupMenu {
  
  /// 在指定位置弹出
  ///
  /// - Parameters:
  ///   - point: 弹出的位置
  func show(at point: CGPoint) {
    
    self.point = point
    self.updateUI()
    
    self.show()
  }
  
  /// 依赖指定view弹出
  ///
  /// - Parameters:
  ///   - view: 依赖的view
  func show(in view: UIView) {
    
    let absoluteRect = view.convert(view.bounds, to: UIApplication.shared.keyWindow)
    let relyPoint = CGPoint(x: absoluteRect.origin.x + absoluteRect.size.width / 2, y: absoluteRect.origin.y + absoluteRect.size.height/2)
    
    self.point = relyPoint
    self.relyRect = absoluteRect
    
    self.updateUI()
    
    self.show()
  }
  
  func hide() {
    
    self.delegate?.popupMenuWillDisappear()
    
    UIView.animate(withDuration: 0.25, animations: {
      
      self.layer.setAffineTransform(CGAffineTransform(scaleX: 0.1, y: 0.1))
      self.alpha = 0
      self.menuBackgroundView.alpha = 0
      
    }, completion: { (isFinished) in
      
      self.delegate?.popupMenuDidDisappear()
      self.delegate = nil
      self.removeFromSuperview()
      self.menuBackgroundView.removeFromSuperview()
    })
  }
}

// MARK: - Action
private extension PopupMenu {
  
  @objc func touchOutside() {
    
    guard isDismissOnTouchOutside == true else { return }
    self.hide()
  }
  
}

// MARK: - Setup
private extension PopupMenu {
  
  var lastVisibleCell: PopupMenuCell? {
    
    guard let indexPath = tableView.indexPathsForVisibleRows?.sorted(by: { $0.row < $1.row}).last else { return nil }
    return tableView.cellForRow(at: indexPath) as? PopupMenuCell
  }
  
  func updateUI() {
    
    var height: CGFloat = 0
    
    if self.items.count > maxVisibleCount {
      
      height = itemHeight * CGFloat(maxVisibleCount) + borderWidth * 2
      tableView.bounces = true
      
    } else {
      
      height = itemHeight * CGFloat(self.items.count) + borderWidth * 2
      tableView.bounces = false
    }
    isChangeDirection = false
    
    if directionPriority == .top {
      
      if point.y + height + arrowHeight > UIScreen.main.bounds.height - minSpace {
        
        arrowDirection = .bottom
        isChangeDirection = true
        
      } else {
        
        arrowDirection = .top
        isChangeDirection = false
      }
      
    } else if directionPriority == .bottom {
      
      if point.y - height - arrowHeight < minSpace {
        
        arrowDirection = .top
        isChangeDirection = true
        
      } else {
        
        arrowDirection = .bottom
        isChangeDirection = false
        
      }
      
    } else if directionPriority == .left {
      
      if point.x + menuWidth + arrowHeight > UIScreen.main.bounds.width - minSpace {
        
        arrowDirection = .right
        isChangeDirection = true
        
      } else {
        
        arrowDirection = .left
        isChangeDirection = false
      }
      
    } else if directionPriority == .right {
      
      if point.x - menuWidth - arrowHeight < minSpace {
        
        arrowDirection = .left
        isChangeDirection = true
        
      } else {
        
        arrowDirection = .right
        isChangeDirection = false
      }
      
    } else { // .none
      
      if point.y + height + arrowHeight > UIScreen.main.bounds.height - minSpace {
        
        isChangeDirection = true
        
      } else {
        
        isChangeDirection = false
      }
      arrowDirection = .none
    }
    
    setArrowPosition()
    setRelyRect()
    
    if arrowDirection == .top {
      
      let y =  point.y
      if arrowOffset > menuWidth / 2 {
        
        frame = CGRect.init(x: UIScreen.main.bounds.width - minSpace - menuWidth, y:y , width: menuWidth, height: height + arrowHeight)
        
      } else if arrowOffset < menuWidth / 2 {
        
        frame = CGRect.init(x: minSpace, y:y , width: menuWidth, height: height + arrowHeight)
        
      } else {
        
        frame = CGRect.init(x: point.x - menuWidth / 2, y:y , width: menuWidth, height: height + arrowHeight)
      }
    } else if arrowDirection == .bottom {
      
      let y = point.y - arrowHeight - height
      if arrowOffset > menuWidth / 2 {
        
        frame = CGRect.init(x: UIScreen.main.bounds.width - minSpace - menuWidth, y:y , width: menuWidth, height: height + arrowHeight)
        
      } else if arrowOffset < menuWidth / 2 {
        
        frame = CGRect.init(x: minSpace, y:y , width: menuWidth, height: height + arrowHeight)
        
      } else {
        
        frame = CGRect.init(x: point.x - menuWidth / 2, y:y , width: menuWidth, height: height + arrowHeight)
      }
      
    } else if arrowDirection == .left {
      
      let x = point.x
      if arrowOffset < itemHeight / 2 {
        
        frame = CGRect.init(x: x , y:point.y - arrowOffset, width: menuWidth + arrowHeight, height: height )
        
      } else if arrowOffset > itemHeight / 2 {
        
        frame = CGRect.init(x: x, y:point.y - arrowOffset, width: menuWidth + arrowHeight, height: height)
        
      } else {
        
        frame = CGRect.init(x: x, y:point.y - arrowOffset, width: menuWidth + arrowHeight, height: height)
      }
      
    } else if arrowDirection == .right {
      
      let x = isChangeDirection ? point.x - menuWidth - arrowHeight - 2*borderWidth : point.x - menuWidth - arrowHeight - 2*borderWidth
      if arrowOffset < itemHeight / 2 {
        
        frame = CGRect.init(x: x , y:point.y - arrowOffset, width: menuWidth + arrowHeight, height: height )
        
      } else if arrowOffset > itemHeight / 2 {
        
        frame = CGRect.init(x: x-menuWidth/2, y:point.y - arrowOffset, width: menuWidth + arrowHeight, height: height)
        
      } else {
        
        frame = CGRect.init(x: x, y:point.y - arrowOffset, width: menuWidth + arrowHeight, height: height)
      }
      
    } else if arrowDirection == .none {
      
      let y = isChangeDirection ? point.y - arrowHeight - height : point.y + arrowHeight
      
      if arrowOffset > menuWidth / 2 {
        
        frame = CGRect.init(x: UIScreen.main.bounds.width - minSpace - menuWidth, y:y , width: menuWidth, height: height )
        
      } else if arrowOffset < menuWidth / 2 {
        
        frame = CGRect.init(x: minSpace, y:y , width: menuWidth, height: height)
        
      } else {
        
        frame = CGRect.init(x: point.x - menuWidth / 2, y:y , width: menuWidth, height: height)
      }
    }
    
    setAnchorPoint()
    setOffset()
    tableView.reloadData()
    if let index = self.defaultSelectedIndex, index < self.items.count {
      tableView.selectRow(at: IndexPath(item: index, section: 0), animated: false, scrollPosition: .none)
    }
    setNeedsDisplay()
  }
  
  func setArrowPosition() {
    
    if directionPriority == .none { return }
    
    guard arrowDirection == .top || arrowDirection == .bottom else { return }
    
    if point.x + menuWidth / 2 > UIScreen.main.bounds.width - minSpace {
      
      arrowOffset = menuWidth - (UIScreen.main.bounds.width - minSpace - point.x)
      
    } else if point.x < menuWidth / 2 + minSpace {
      
      arrowOffset = point.x - minSpace
      
    } else {
      
      arrowOffset = menuWidth / 2
    }
  }
  
  func setRelyRect() {
    
    if self.relyRect == .zero { return }
    
    if arrowDirection == .top {
      
      point.y = relyRect.size.height + relyRect.origin.y
      
    } else if arrowDirection == .bottom {
      
      point.y = relyRect.origin.y
      
    } else if arrowDirection == .left {
      
      point = CGPoint.init(x: relyRect.origin.x + relyRect.size.width, y: relyRect.origin.y + relyRect.size.height / 2)
      
    } else if arrowDirection == .right {
      
      point = CGPoint.init(x: relyRect.origin.x + relyRect.size.width, y: relyRect.origin.y + relyRect.size.height / 2)
      
    } else { // none
      
      if isChangeDirection == true {
        point = CGPoint.init(x: relyRect.origin.x + relyRect.size.width/2, y: relyRect.origin.y)
      } else {
        point = CGPoint.init(x: relyRect.origin.x + relyRect.size.width/2, y: relyRect.origin.y + relyRect.size.height )
      }
    }
  }
  
  func setAnchorPoint() {
    
    if self.menuWidth == 0 { return }
    
    var point = CGPoint(x: 0.5, y: 0.5)
    if arrowDirection == .top {
      
      point = CGPoint(x: arrowOffset / menuWidth, y: 0)
      
    } else if arrowDirection == .bottom {
      
      point = CGPoint(x: arrowOffset / menuWidth, y: 1)
      
    } else if arrowDirection == .left {
      
      point = CGPoint(x: 0 , y: (itemHeight - arrowOffset) / itemHeight)
      
    } else if arrowDirection == .right {
      
      point = CGPoint(x: 0, y: (itemHeight - arrowOffset) / itemHeight)
      
    } else if arrowDirection == .none {
      
      if isChangeDirection == true {
        
        point = CGPoint(x: arrowOffset / menuWidth, y: 1)
        
      } else {
        
        point = CGPoint(x: arrowOffset / menuWidth, y: 0)
      }
    }
    
    let originRect = self.frame
    self.layer.anchorPoint = point
    self.frame = originRect
  }
  
  func setOffset() {
    
    if self.menuWidth == 0 { return }
    
    var originRect = frame
    switch arrowDirection {
    case .top: originRect.origin.y += offset
    case .bottom: originRect.origin.y -= offset
    case .left: originRect.origin.y += offset
    case .right: originRect.origin.y -= offset
    default: break
    }
    
    self.frame = originRect
  }
  
}

// MARK: - Utility
private extension PopupMenu {
  
  func show() {
    
    UIApplication.shared.keyWindow?.addSubview(self.menuBackgroundView)
    UIApplication.shared.keyWindow?.addSubview(self)
    
    let cell = lastVisibleCell
    cell?.isShowSeparator = false
    self.delegate?.popupMenuWillAppear()
    
    self.layer.setAffineTransform(CGAffineTransform(scaleX: 0.1, y: 0.1))
    
    UIView.animate(withDuration: 0.25, animations: {
      
      self.layer.setAffineTransform(CGAffineTransform(scaleX: 1.0, y: 1.0))
      self.alpha = 1
      self.menuBackgroundView.alpha = 1
      
    }, completion: { (_) in
      
      self.delegate?.popupMenuDidAppear()
    })
    
  }
  
//  func hide() {
//    
//    self.delegate?.popupMenuWillDisappear()
//    
//    UIView.animate(withDuration: 0.25, animations: {
//      
//      self.layer.setAffineTransform(CGAffineTransform(scaleX: 0.1, y: 0.1))
//      self.alpha = 0
//      self.menuBackgroundView.alpha = 0
//      
//    }, completion: { (isFinished) in
//      
//      self.delegate?.popupMenuDidDisappear()
//      self.delegate = nil
//      self.removeFromSuperview()
//      self.menuBackgroundView.removeFromSuperview()
//    })
//  }
  
  func drawBezierPath(with myRect: CGRect) {
    
    let backgroundColor = backColor
    let myArrowPosition = arrowOffset
    
    let bezierPath = UIBezierPath()
    borderColor.setStroke()
    backgroundColor.setFill()
    
    bezierPath.lineWidth = borderWidth
    
    let rect = CGRect.init(x: borderWidth / 2, y: borderWidth / 2, width: myRect.width - borderWidth, height: myRect.height - borderWidth)
    
    var topRightRadius : CGFloat = 0
    var topLeftRadius : CGFloat = 0
    var bottomRightRadius : CGFloat = 0
    var bottomLeftRadius : CGFloat = 0
    
    var topRightArcCenter : CGPoint = CGPoint.zero
    var topLeftArcCenter : CGPoint = CGPoint.zero
    var bottomRightArcCenter : CGPoint = CGPoint.zero
    var bottomLeftArcCenter : CGPoint = CGPoint.zero
    
    if rectCorner.contains(UIRectCorner.topLeft) {
      topLeftRadius = cornerRadius
    }
    if rectCorner.contains(UIRectCorner.topRight) {
      topRightRadius = cornerRadius
    }
    if rectCorner.contains(UIRectCorner.bottomLeft) {
      bottomLeftRadius = cornerRadius
    }
    if rectCorner.contains(UIRectCorner.bottomRight) {
      bottomRightRadius = cornerRadius
    }
    
    
    if arrowDirection == .top {
      topLeftArcCenter = CGPoint.init(x: topLeftRadius + rect.minX, y: arrowHeight + topLeftRadius + rect.minX)
      topRightArcCenter = CGPoint.init(x: rect.width - topRightRadius + rect.minX, y: arrowHeight + topRightRadius + rect.minX)
      bottomLeftArcCenter = CGPoint.init(x: bottomLeftRadius + rect.minX, y: rect.height - bottomLeftRadius + rect.minX)
      bottomRightArcCenter = CGPoint.init(x: rect.width - bottomRightRadius + rect.minX, y: rect.height - bottomRightRadius + rect.minX)
      var arrowPosition : CGFloat = 0
      if myArrowPosition < topLeftRadius + arrowWidth / 2 {
        arrowPosition = topLeftRadius + arrowWidth / 2
      }else if myArrowPosition > rect.width - topRightRadius - arrowWidth / 2 {
        arrowPosition = rect.width - topRightRadius - arrowWidth / 2
      }else{
        arrowPosition = myArrowPosition
      }
      
      bezierPath.move(to: CGPoint.init(x: arrowPosition - arrowWidth / 2, y: arrowHeight + rect.minX))
      bezierPath.addLine(to: CGPoint.init(x: arrowPosition, y: rect.minY + rect.minX))
      bezierPath.addLine(to: CGPoint.init(x: arrowPosition + arrowWidth / 2, y: arrowHeight + rect.minX))
      bezierPath.addLine(to: CGPoint.init(x: rect.width - topRightRadius, y: arrowHeight + rect.minX))
      bezierPath.addArc(withCenter: topRightArcCenter, radius: topRightRadius, startAngle: CGFloat.pi * 3 / 2, endAngle: CGFloat.pi * 2, clockwise: true)
      bezierPath.addLine(to: CGPoint.init(x: rect.width + rect.minX, y: rect.height - bottomRightRadius - rect.minX))
      bezierPath.addArc(withCenter: bottomRightArcCenter, radius: bottomRightRadius, startAngle: 0, endAngle: CGFloat.pi*0.5, clockwise: true)
      bezierPath.addLine(to: CGPoint.init(x: bottomLeftRadius + rect.minX, y: rect.height + rect.minX))
      
      bezierPath.addArc(withCenter: bottomLeftArcCenter, radius: bottomLeftRadius, startAngle: CGFloat.pi*0.5, endAngle: CGFloat.pi, clockwise: true)
      bezierPath.addLine(to: CGPoint.init(x: rect.minX, y: arrowHeight + topLeftRadius + rect.minX))
      bezierPath.addArc(withCenter: topLeftArcCenter, radius: topLeftRadius, startAngle: CGFloat.pi, endAngle: CGFloat.pi * 3 / 2, clockwise: true)
    }else if arrowDirection == .bottom {// 箭头朝下
      
      topLeftArcCenter = CGPoint.init(x: topLeftRadius + rect.minX, y: topLeftRadius + rect.minX)
      topRightArcCenter = CGPoint.init(x: rect.width - topRightRadius + rect.minX, y: topRightRadius + rect.minX)
      bottomLeftArcCenter = CGPoint.init(x: bottomLeftRadius + rect.minX, y: rect.height - bottomLeftRadius + rect.minX - arrowHeight)
      bottomRightArcCenter = CGPoint.init(x: rect.width - bottomRightRadius + rect.minX, y: rect.height - bottomRightRadius + rect.minX - arrowHeight)
      var arrowPosition : CGFloat = 0
      if myArrowPosition < bottomLeftRadius + arrowWidth / 2 {
        arrowPosition = bottomLeftRadius + arrowWidth / 2
      }else if arrowPosition > rect.width - bottomRightRadius - arrowWidth / 2 {
        arrowPosition = rect.width - bottomRightRadius - arrowWidth / 2
      }else{
        arrowPosition = myArrowPosition
      }
      
      bezierPath.move(to: CGPoint.init(x: arrowPosition + arrowWidth / 2, y: rect.height - arrowHeight + rect.minX))
      bezierPath.addLine(to: CGPoint.init(x: arrowPosition, y: rect.height + rect.minX))
      bezierPath.addLine(to: CGPoint.init(x: arrowPosition - arrowWidth / 2, y: rect.height - arrowHeight + rect.minX))
      bezierPath.addLine(to: CGPoint.init(x: bottomLeftRadius + rect.minX, y: rect.height - arrowHeight + rect.minX))
      bezierPath.addArc(withCenter: bottomLeftArcCenter, radius: bottomLeftRadius, startAngle: CGFloat.pi / 2, endAngle: CGFloat.pi, clockwise: true)
      bezierPath.addLine(to: CGPoint.init(x: rect.minX, y: topLeftRadius + rect.minX))
      bezierPath.addArc(withCenter: topLeftArcCenter, radius: topLeftRadius, startAngle: CGFloat.pi, endAngle: CGFloat.pi * 3 / 2, clockwise: true)
      bezierPath.addLine(to: CGPoint.init(x: rect.width - topRightRadius + rect.minX, y: rect.minX))
      bezierPath.addArc(withCenter: topRightArcCenter, radius: topRightRadius, startAngle: CGFloat.pi * 3 / 2, endAngle: CGFloat.pi * 2, clockwise: true)
      bezierPath.addLine(to: CGPoint.init(x: rect.width + rect.minX, y: rect.height - bottomRightRadius - rect.minX - arrowHeight))
      bezierPath.addArc(withCenter: bottomRightArcCenter, radius: bottomRightRadius, startAngle: 0, endAngle: CGFloat.pi / 2, clockwise: true)
    }else if arrowDirection == .left { // 箭头朝左
      
      topLeftArcCenter = CGPoint.init(x: topLeftRadius + rect.minX + arrowHeight, y: topLeftRadius + rect.minX)
      topRightArcCenter = CGPoint.init(x: rect.width - topRightRadius + rect.minX, y: topRightRadius + rect.minX)
      bottomLeftArcCenter = CGPoint.init(x: bottomLeftRadius + rect.minX + arrowHeight, y: rect.height - bottomLeftRadius + rect.minX)
      bottomRightArcCenter = CGPoint.init(x: rect.width - bottomRightRadius + rect.minX, y: rect.height - bottomRightRadius + rect.minX)
      
      var arrowPosition : CGFloat = 0
      if myArrowPosition < topLeftRadius + arrowWidth / 2 {
        arrowPosition = topLeftRadius + arrowWidth / 2
      }else if arrowPosition > rect.height - bottomLeftRadius - arrowWidth / 2 {
        arrowPosition = rect.height - bottomLeftRadius - arrowWidth / 2
      }else{
        arrowPosition = myArrowPosition
      }
      
      bezierPath.move(to: CGPoint.init(x: arrowHeight + rect.minX, y: arrowPosition + arrowWidth / 2))
      bezierPath.addLine(to: CGPoint.init(x: rect.minX, y: arrowPosition))
      bezierPath.addLine(to: CGPoint.init(x: arrowHeight + rect.minX, y: arrowPosition - arrowWidth / 2))
      bezierPath.addLine(to: CGPoint.init(x: arrowHeight + rect.minX, y: topLeftRadius + rect.minX))
      bezierPath.addArc(withCenter: topLeftArcCenter, radius: topLeftRadius, startAngle: CGFloat.pi, endAngle: CGFloat.pi*3/2, clockwise: true)
      bezierPath.addLine(to: CGPoint.init(x: rect.width - topRightRadius, y: rect.minX))
      bezierPath.addArc(withCenter: topRightArcCenter, radius: topRightRadius, startAngle: CGFloat.pi*3/2, endAngle: CGFloat.pi*2, clockwise: true)
      bezierPath.addLine(to: CGPoint.init(x: rect.width + rect.minX, y: rect.height - bottomRightRadius - rect.minX))
      bezierPath.addArc(withCenter: bottomRightArcCenter, radius: bottomRightRadius, startAngle: 0, endAngle: CGFloat.pi*0.5, clockwise: true)
      bezierPath.addLine(to: CGPoint.init(x: arrowHeight + bottomLeftRadius + rect.minX, y: rect.height + rect.minX))
      bezierPath.addArc(withCenter: bottomLeftArcCenter, radius: bottomLeftRadius, startAngle: CGFloat.pi*0.5, endAngle: CGFloat.pi, clockwise: true)
    }else if arrowDirection == .right{ // 箭头朝右
      
      topLeftArcCenter = CGPoint.init(x: topLeftRadius + rect.minX, y: topLeftRadius + rect.minX)
      topRightArcCenter = CGPoint.init(x: rect.width - topRightRadius + rect.minX - arrowHeight, y: topRightRadius + rect.minX)
      bottomLeftArcCenter = CGPoint.init(x: bottomLeftRadius + rect.minX , y: rect.height - bottomLeftRadius + rect.minX)
      bottomRightArcCenter = CGPoint.init(x: rect.width - bottomRightRadius + rect.minX - arrowHeight, y: rect.height - bottomRightRadius + rect.minX)
      
      var arrowPosition : CGFloat = 0
      if myArrowPosition < topRightRadius + arrowWidth / 2 {
        arrowPosition = topRightRadius + arrowWidth / 2
      }else if arrowPosition > rect.height - bottomRightRadius - arrowWidth / 2 {
        arrowPosition = rect.height - bottomRightRadius - arrowWidth / 2
      }else{
        arrowPosition = myArrowPosition
      }
      
      bezierPath.move(to: CGPoint.init(x: rect.width - arrowHeight + rect.minX, y: arrowPosition - arrowWidth / 2))
      bezierPath.addLine(to: CGPoint.init(x: rect.width + rect.minX, y: arrowPosition))
      bezierPath.addLine(to: CGPoint.init(x: rect.width - arrowHeight + rect.minX, y: arrowPosition + arrowWidth / 2))
      
      bezierPath.addLine(to: CGPoint.init(x: rect.width - arrowHeight + rect.minX, y: rect.height - bottomRightRadius - rect.minX))
      bezierPath.addArc(withCenter: bottomRightArcCenter, radius: bottomRightRadius, startAngle: 0, endAngle: CGFloat.pi/2, clockwise: true)
      bezierPath.addLine(to: CGPoint.init(x: bottomLeftRadius + rect.minX, y: rect.height + rect.minX))
      bezierPath.addArc(withCenter: bottomLeftArcCenter, radius: bottomLeftRadius, startAngle: CGFloat.pi/2, endAngle: CGFloat.pi, clockwise: true)
      bezierPath.addLine(to: CGPoint.init(x: rect.minX, y: arrowHeight + topLeftRadius + rect.minX))
      bezierPath.addArc(withCenter: topLeftArcCenter, radius: topLeftRadius, startAngle: CGFloat.pi, endAngle: CGFloat.pi*0.5*3, clockwise: true)
      bezierPath.addLine(to: CGPoint.init(x: rect.width - topRightRadius + rect.minX - arrowHeight, y: rect.minX))
      bezierPath.addArc(withCenter: topRightArcCenter, radius: topRightRadius, startAngle: CGFloat.pi*0.5*3, endAngle: CGFloat.pi*2, clockwise: true)
    }else if arrowDirection == .none{ // 无箭头
      
      topLeftArcCenter = CGPoint.init(x: topLeftRadius + rect.minX, y: topLeftRadius + rect.minX)
      topRightArcCenter = CGPoint.init(x: rect.width - topRightRadius + rect.minX, y: topRightRadius + rect.minX)
      bottomLeftArcCenter = CGPoint.init(x: bottomLeftRadius + rect.minX , y: rect.height - bottomLeftRadius + rect.minX)
      bottomRightArcCenter = CGPoint.init(x: rect.width - bottomRightRadius + rect.minX, y: rect.height - bottomRightRadius + rect.minX)
      
      
      bezierPath.move(to: CGPoint.init(x: topLeftRadius + rect.minX, y: rect.minX))
      bezierPath.addLine(to: CGPoint.init(x: rect.width - topRightRadius, y: rect.minX))
      
      bezierPath.addArc(withCenter: topRightArcCenter, radius: topRightRadius, startAngle: CGFloat.pi*0.5*3, endAngle: CGFloat.pi*2, clockwise: true)
      
      bezierPath.addLine(to: CGPoint.init(x: rect.width + rect.minX, y: rect.height - bottomRightRadius - rect.minX))
      
      bezierPath.addArc(withCenter: bottomRightArcCenter, radius: bottomRightRadius, startAngle: 0, endAngle: CGFloat.pi/2, clockwise: true)
      
      bezierPath.addLine(to: CGPoint.init(x: bottomLeftRadius + rect.minX, y: rect.height + rect.minX))
      
      bezierPath.addArc(withCenter: bottomLeftArcCenter, radius: bottomLeftRadius, startAngle: CGFloat.pi/2, endAngle: CGFloat.pi, clockwise: true)
      
      bezierPath.addLine(to: CGPoint.init(x: rect.minX , y: arrowHeight + topLeftRadius + rect.minX))
      bezierPath.addArc(withCenter: topLeftArcCenter, radius: topLeftRadius, startAngle: CGFloat.pi, endAngle: CGFloat.pi*3/2, clockwise: true)
    }
    bezierPath.close()
    
    bezierPath.fill()
    bezierPath.stroke()
  }

}

// MARK: - ScrollViewDelegate
extension PopupMenu {
  
  public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
    
    self.lastVisibleCell?.isShowSeparator = true
  }
  
  public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    
    self.lastVisibleCell?.isShowSeparator = false
  }
  
}

// MARK: - UITableViewDelegate
extension PopupMenu: UITableViewDelegate {
  
  public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
    defer {
      
      self.hide()
    }
    
    if self.defaultSelectedIndex == indexPath.item { return }
    
    self.selectedHandle?(indexPath.row)
    self.delegate?.popupMenu(self, didSelectAt: indexPath.row)
  }
  
}

// MARK: - UITableViewDataSource
extension PopupMenu: UITableViewDataSource {
  
  public func numberOfSections(in tableView: UITableView) -> Int {
    
    return 1
  }
  
  public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
    return self.items.count
  }
  
  public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    let cell = tableView.dequeueReusableCell(withIdentifier: ReuseItem(PopupMenuCell.self).id, for: indexPath)
    
    if let cell = cell as? PopupMenuCell {
      
      cell.update(with: self.items[indexPath.item])
      cell.updateText(self.font)
      cell.updateText(self.textAlignment)
      cell.normalColor = self.textColor
      cell.selectedColor = self.selectedTextColor
      
      cell.separatorColor = self.separatorColor ?? .lightGray
    }
    
    return cell
  }
  
}
