//
//  PopupMenu.swift
//  VideoModule
//
//  Created by Hiu on 2018/6/6.
//  Copyright © 2018年 飞进科技. All rights reserved.
//

import ApplicationKit

public enum PopupMenuType {
  
  case white //Default
  case dark
}

/// 箭头方向优先级,当控件超出屏幕时会自动调整成反方向
public enum PopupMenuPriorityDirection {
  
  case top
  case bottom
  case left
  case right
  case none //不自动调整
}

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
  
  /// 圆角半径 Default is 5.0
  public var cornerRadius: CGFloat = 5.0
  
  /// 自定义圆角 Default is UIRectCorner.allCorners,当自动调整方向时corner会自动转换至镜像方向
  public var rectCorner: UIRectCorner = .allCorners {
    
    didSet{
      // updateUI()
    }
  }
  
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
  
  /// 选择菜单项后消失 Default is YES
  public var dismissOnSelected: Bool = true
  
  /// 点击菜单外消失  Default is YES
  public var dismissOnTouchOutside: Bool = true
  
  /// 设置字体大小 Default is 15
  public var fontSize: CGFloat = 15
  
  /// 设置字体颜色 Default is UIColor.black
  public var textColor: UIColor = .black {
    
    didSet{
      // tableView.reloadData()
    }
  }
  
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
  
  /// 箭头位置 Default is center, 只有箭头优先级是YBPopupMenuPriorityDirectionLeft/YBPopupMenuPriorityDirectionRight/YBPopupMenuPriorityDirectionNone时需要设置
  public var arrowPosition: CGFloat = 0
  
  public var isCornerChanged: Bool = false
  public var isChangeDirection: Bool = false
  public var separatorColor: UIColor?
  
  /// 箭头方向 Default is PopupMenuArrowDirection.top
  public var arrowDirection: PopupMenuArrowDirection = .top
  
  /// 箭头优先方向 Default is PopupMenuArrowDirection.top,当控件超出屏幕时会自动调整箭头位置
  public var priorityDirection: PopupMenuPriorityDirection = .top
  
  /// 可见的最大行数 Default is 5;
  public var maxVisibleCount: Int = 5
  
  /// menu背景色 Default is WhiteColor
  public var backColor: UIColor = .white
  
  /// item的高度 Default is 44;
  public var itemHeight: CGFloat = 44 {
    
    didSet {
      
      self.tableView.rowHeight = itemHeight
      self.updateUI()
    }
  }
  
  /// 设置显示模式 Default is PopupMenuType.defaultWhite
  public var type: PopupMenuType = .white {
    
    didSet {
      
      switch type {
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
  /// 点击选中回调
  private var selectedHandle: SelectedHandle?
  
  private var menuBackgroundView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
  private var relyRect: CGRect = .zero
  private var minSpace: CGFloat = 10.0
  private var itemWidth: CGFloat = 0
  
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
  
  
  private var titles: [String] = []
  private var images: [String] = []
  private var point: CGPoint = .zero
  
  private let tableView = UITableView.init(frame: CGRect.zero, style: UITableView.Style.plain)
  
  public init(menuWidth: CGFloat, titles: [String], images: [String] = [], delegate: PopupMenuDelegate) {
    self.init()
    
    self.titles = titles
    self.images = images
    self.itemWidth = menuWidth
    self.delegate = delegate
  }
  
  public typealias SelectedHandle = (_ index: Int, _ title: String, _ popupMenu: PopupMenu) -> Void
  public init(menuWidth: CGFloat, titles: [String], images: [String] = [], selected handle: @escaping SelectedHandle) {
    self.init()
    
    self.titles = titles
    self.images = images
    self.itemWidth = menuWidth
    self.selectedHandle = handle
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    self.type = .white
    self.menuBackgroundView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.1)
    self.menuBackgroundView.alpha = 0
    let tap = UITapGestureRecognizer(target: self, action: #selector(touchOutside))
    self.menuBackgroundView.addGestureRecognizer(tap)
    self.alpha = 0
    self.backgroundColor = UIColor.clear
    
    self.tableView.delegate = self
    self.tableView.dataSource = self
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
    
    let bezierPath = PopupMenuPath.bezierPathWithRect(myRect: rect, rectCorner: self.rectCorner, cornerRadius: cornerRadius, borderWidth: borderWidth, borderColor: borderColor, backgroundColor: backColor, arrowWidth: arrowWidth, arrowHeight: arrowHeight, myArrowPosition: arrowPosition, arrowDirection: arrowDirection)
    bezierPath.fill()
    bezierPath.stroke()
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
  
}

// MARK: - Action
private extension PopupMenu {
  
  @objc func touchOutside() {
    
    guard dismissOnTouchOutside == true else { return }
    self.hide()
  }
  
}

// MARK: - Setup
private extension PopupMenu {
  
  func updateUI() {
    
    var height: CGFloat = 0
    
    if titles.count > maxVisibleCount {
      
      height = itemHeight * CGFloat(maxVisibleCount) + borderWidth * 2
      tableView.bounces = true
      
    } else {
      
      height = itemHeight * CGFloat(titles.count) + borderWidth * 2
      tableView.bounces = false
    }
    isChangeDirection = false
    
    if priorityDirection == .top {
      
      if point.y + height + arrowHeight > UIScreen.main.bounds.height - minSpace {
        
        arrowDirection = PopupMenuArrowDirection.bottom
        isChangeDirection = true
        
      } else {
        
        arrowDirection = PopupMenuArrowDirection.top
        isChangeDirection = false
      }
      
    } else if priorityDirection == .bottom {
      
      if point.y - height - arrowHeight < minSpace {
        
        arrowDirection = PopupMenuArrowDirection.top
        isChangeDirection = true
        
      } else {
        
        arrowDirection = PopupMenuArrowDirection.bottom
        isChangeDirection = false
        
      }
    } else if priorityDirection == .left {
      
      if point.x + itemWidth + arrowHeight > UIScreen.main.bounds.width - minSpace {
        
        arrowDirection = PopupMenuArrowDirection.right
        isChangeDirection = true
        
      } else {
        
        arrowDirection = PopupMenuArrowDirection.left
        isChangeDirection = false
      }
      
    } else if priorityDirection == .right {
      
      if point.x - itemWidth - arrowHeight < minSpace {
        
        arrowDirection = PopupMenuArrowDirection.left
        isChangeDirection = true
        
      } else {
        
        arrowDirection = PopupMenuArrowDirection.right
        isChangeDirection = false
      }
    } else { // .none
      
      if point.y + height + arrowHeight > UIScreen.main.bounds.height - minSpace {
        
        isChangeDirection = true
        
      } else {
        
        isChangeDirection = false
      }
      arrowDirection = PopupMenuArrowDirection.none
    }
    
    setArrowPosition()
    setRelyRect()
    
    if arrowDirection == .top {
      
      let y =  point.y
      if arrowPosition > itemWidth / 2 {
        
        frame = CGRect.init(x: UIScreen.main.bounds.width - minSpace - itemWidth, y:y , width: itemWidth, height: height + arrowHeight)
        
      } else if arrowPosition < itemWidth / 2 {
        
        frame = CGRect.init(x: minSpace, y:y , width: itemWidth, height: height + arrowHeight)
        
      } else {
        
        frame = CGRect.init(x: point.x - itemWidth / 2, y:y , width: itemWidth, height: height + arrowHeight)
      }
    } else if arrowDirection == .bottom {
      
      let y = point.y - arrowHeight - height
      if arrowPosition > itemWidth / 2 {
        
        frame = CGRect.init(x: UIScreen.main.bounds.width - minSpace - itemWidth, y:y , width: itemWidth, height: height + arrowHeight)
        
      } else if arrowPosition < itemWidth / 2 {
        
        frame = CGRect.init(x: minSpace, y:y , width: itemWidth, height: height + arrowHeight)
        
      } else {
        
        frame = CGRect.init(x: point.x - itemWidth / 2, y:y , width: itemWidth, height: height + arrowHeight)
      }
      
    } else if arrowDirection == .left {
      
      let x = point.x
      if arrowPosition < itemHeight / 2 {
        
        frame = CGRect.init(x: x , y:point.y - arrowPosition, width: itemWidth + arrowHeight, height: height )
        
      } else if arrowPosition > itemHeight / 2 {
        
        frame = CGRect.init(x: x, y:point.y - arrowPosition, width: itemWidth + arrowHeight, height: height)
        
      } else {
        
        frame = CGRect.init(x: x, y:point.y - arrowPosition, width: itemWidth + arrowHeight, height: height)
      }
      
    } else if arrowDirection == .right {
      
      let x = isChangeDirection ? point.x - itemWidth - arrowHeight - 2*borderWidth : point.x - itemWidth - arrowHeight - 2*borderWidth
      if arrowPosition < itemHeight / 2 {
        
        frame = CGRect.init(x: x , y:point.y - arrowPosition, width: itemWidth + arrowHeight, height: height )
        
      } else if arrowPosition > itemHeight / 2 {
        
        frame = CGRect.init(x: x-itemWidth/2, y:point.y - arrowPosition, width: itemWidth + arrowHeight, height: height)
        
      } else {
        
        frame = CGRect.init(x: x, y:point.y - arrowPosition, width: itemWidth + arrowHeight, height: height)
      }
      
    } else if arrowDirection == .none {
      
      let y = isChangeDirection ? point.y - arrowHeight - height : point.y + arrowHeight
      
      if arrowPosition > itemWidth / 2 {
        
        frame = CGRect.init(x: UIScreen.main.bounds.width - minSpace - itemWidth, y:y , width: itemWidth, height: height )
        
      } else if arrowPosition < itemWidth / 2 {
        
        frame = CGRect.init(x: minSpace, y:y , width: itemWidth, height: height)
        
      } else {
        
        frame = CGRect.init(x: point.x - itemWidth / 2, y:y , width: itemWidth, height: height)
      }
    }
    
    setAnchorPoint()
    setOffset()
    tableView.reloadData()
    setNeedsDisplay()
  }
  
  func setArrowPosition() {
    
    if priorityDirection == .none { return }
    
    guard arrowDirection == .top || arrowDirection == .bottom else { return }
    
    if point.x + itemWidth / 2 > UIScreen.main.bounds.width - minSpace {
      
      arrowPosition = itemWidth - (UIScreen.main.bounds.width - minSpace - point.x)
      
    } else if point.x < itemWidth / 2 + minSpace {
      
      arrowPosition = point.x - minSpace
      
    } else {
      
      arrowPosition = itemWidth / 2
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
    
    if self.itemWidth == 0 { return }
    
    var point = CGPoint(x: 0.5, y: 0.5)
    if arrowDirection == .top {
      
      point = CGPoint(x: arrowPosition / itemWidth, y: 0)
      
    } else if arrowDirection == .bottom {
      
      point = CGPoint(x: arrowPosition / itemWidth, y: 1)
      
    } else if arrowDirection == .left {
      
      point = CGPoint(x: 0 , y: (itemHeight - arrowPosition) / itemHeight)
      
    } else if arrowDirection == .right {
      
      point = CGPoint(x: 0, y: (itemHeight - arrowPosition) / itemHeight)
      
    } else if arrowDirection == .none {
      
      if isChangeDirection == true {
        
        point = CGPoint(x: arrowPosition / itemWidth, y: 1)
        
      } else {
        
        point = CGPoint(x: arrowPosition / itemWidth, y: 0)
      }
    }
    
    let originRect = self.frame
    self.layer.anchorPoint = point
    self.frame = originRect
  }
  
  func setOffset() {
    
    if self.itemWidth == 0 { return }
    
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
    
    let cell: PopupMenuCell = lastVisibleCell()
    cell.isShowSeparator = false
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

// MARK: - ScrollViewDelegate
extension PopupMenu {
  
  public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
    
    lastVisibleCell().isShowSeparator = true
  }
  
  public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    
    lastVisibleCell().isShowSeparator = false
  }
  
  func lastVisibleCell() -> PopupMenuCell {
    
    var indexPaths = tableView.indexPathsForVisibleRows
    indexPaths = indexPaths?.sorted{ (obj1, obj2) -> Bool in
      return obj1.row < obj2.row
    }
    let indexPath = indexPaths?.last
    return tableView.cellForRow(at: indexPath!) as! PopupMenuCell
  }
  
}

// MARK: - UITableViewDelegate
extension PopupMenu: UITableViewDelegate {
  
  public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
    tableView.deselectRow(at: indexPath, animated: true)
    
    self.selectedHandle?(indexPath.row,titles[indexPath.row],self)
    self.delegate?.popupMenu(self, didSelectAt: indexPath.row)
    self.hide()
    
  }
  
}

// MARK: - UITableViewDataSource
extension PopupMenu: UITableViewDataSource {
  
  public func numberOfSections(in tableView: UITableView) -> Int {
    
    return 1
  }
  
  public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
    return titles.count
  }
  
  public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    let cell = tableView.dequeueReusableCell(withIdentifier: ReuseItem(PopupMenuCell.self).id, for: indexPath)
    
    if let cell = cell as? PopupMenuCell {
    
      cell.updateText(self.textColor)
      cell.updateText(UIFont.systemFont(ofSize: self.fontSize))
      cell.updateText(self.titles[indexPath.row])
      cell.updateImage(self.images.count > indexPath.row ? self.images[indexPath.row] : nil)
      cell.separatorColor = self.separatorColor ?? .lightGray
    }
    
    return cell
  }
  
}







