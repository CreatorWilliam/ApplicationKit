//
//  DatePickerViewController.swift
//  ComponentKit
//
//  Created by William Lee on 2019/8/5.
//  Copyright © 2019 广州飞进信息科技有限公司. All rights reserved.
//

import ApplicationKit
import UIKit

public class DatePickerViewController: UIViewController {
  
  public override var title: String? {
    set { titleLabel.text = newValue }
    get { return titleLabel.text }
  }
  /// 设置显示的模式
  public var mode: Mode = .date {
    didSet {
      
      switch mode {
      case .date: dateFormatter.dateFormat = "yyyy-MM-dd"
      case .time: dateFormatter.dateFormat = "HH:mm:ss"
      case .dateAndHour: dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
      case .dateAndHourAndMinute: dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
      case .dateAndTime: dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
      case .countDownTimer: break
      }
    }
  }
  /// 选中的日期
  public var date: Date = Date()
  /// 可选的最小时间
  public var minimumDate: Date?
  /// 可选的最大时间
  public var maximumDate: Date?
  /// 日期格式化
  public let dateFormatter = DateFormatter()
  /// 执行完后进行回调
  public var completionHandle: ((_ date: Date, _ dateString: String) -> Void)?
  
  private let contentView = UIView()
  private let topToolView = UIView()
  private let titleLabel = UILabel()
  private let cancelButton = UIButton(type: .custom)
  private let confirmButton = UIButton(type: .custom)
  private let customizeDatePickerView = UIPickerView()
  private let systemDatePickerView = UIDatePicker()
  
  private var sortedCalendarComponents: [Calendar.Component] = []
  private lazy var dateComponents = Calendar.current.dateComponents(Set(sortedCalendarComponents), from: date)
  
  public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    
    let delegate = AnimateTransitioning()
    delegate.isTouchMaskHide = false
    transitioningDelegate = delegate
    modalPresentationStyle = .custom
    
    dateFormatter.dateFormat = "yyyy-MM-dd"
    //dateFormatter.timeZone = TimeZone(secondsFromGMT: 8)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    
    switch mode {
    case .date: sortedCalendarComponents = [.year, .month, .day]
    case .time: sortedCalendarComponents = [.hour, .minute, .second]
    case .dateAndHour: sortedCalendarComponents = [.year, .month, .day, .hour]
    case .dateAndHourAndMinute: sortedCalendarComponents = [.year, .month, .day, .hour, .minute]
    case .dateAndTime: sortedCalendarComponents = [.year, .month, .day, .hour, .minute, .second]
    case .countDownTimer: sortedCalendarComponents = []
    }
    
    /// 时间对齐
    if let minimumDate = minimumDate {
      
      self.minimumDate = date(from: dateComponents(from: minimumDate))
    }
    /// 时间对齐
    if let maximumDate = maximumDate {
      
      self.maximumDate = date(from: dateComponents(from: maximumDate))
    }
    
    setupUI()
    
    set(date, animated: false)
  }
  
}

// MARK: - Public
public extension DatePickerViewController {
  
  /// 显示内容模式
  enum Mode {
    /// 显示年、月、日
    case date
    /// 显示时、分、秒
    case time
    /// 显示年、月、日、时
    case dateAndHour
    /// 显示年、月、日、时、分
    case dateAndHourAndMinute
    /// 显示年、月、日、时、分、秒
    case dateAndTime
    /// 倒计时
    case countDownTimer
  }
  
}

// MARK: - Setup
private extension DatePickerViewController {
  
  func setupUI() {
    
    switch mode {
    case .date:
      
      systemDatePickerView.datePickerMode = .date
      systemDatePickerView.isHidden = true
      customizeDatePickerView.isHidden = false
      
    case .time:
      
      systemDatePickerView.datePickerMode = .time
      systemDatePickerView.isHidden = true
      customizeDatePickerView.isHidden = false
      
    case .dateAndHour,
         .dateAndHourAndMinute:
      
      systemDatePickerView.datePickerMode = .dateAndTime
      systemDatePickerView.isHidden = true
      customizeDatePickerView.isHidden = false
      
    case .dateAndTime:
      
      systemDatePickerView.datePickerMode = .dateAndTime
      systemDatePickerView.isHidden = false
      customizeDatePickerView.isHidden = true
      
    case .countDownTimer:
      
      systemDatePickerView.datePickerMode = .countDownTimer
      systemDatePickerView.isHidden = false
      customizeDatePickerView.isHidden = true
    }
    
    contentView.backgroundColor = .white
    view.addSubview(contentView)
    contentView.layout.add { (make) in
      make.leading().trailing().bottom().equal(view)
    }
    
    setupTopToolView()
    contentView.addSubview(topToolView)
    topToolView.layout.add { (make) in
      make.top().leading().trailing().equal(contentView)
      make.height(50)
    }
    
    customizeDatePickerView.delegate = self
    customizeDatePickerView.dataSource = self
    contentView.addSubview(customizeDatePickerView)
    customizeDatePickerView.layout.add { (make) in
      make.top().equal(topToolView).bottom()
      make.leading().trailing().equal(contentView)
      make.bottom().equal(contentView).safeBottom()
    }
    
    contentView.addSubview(systemDatePickerView)
    systemDatePickerView.layout.add { (make) in
      make.top().equal(topToolView).bottom()
      make.leading().trailing().equal(contentView)
      make.bottom().equal(contentView).safeBottom()
    }
  }
  
  func setupTopToolView() {
    
    topToolView.backgroundColor = UIColor(0xf8f8f8)
    
    cancelButton.setTitle("取消", for: .normal)
    cancelButton.setTitleColor(UIColor(0x383e5a), for: .normal)
    cancelButton.titleLabel?.font = Font.system(14)
    cancelButton.addTarget(self, action: #selector(clickCancel(_:)), for: .touchUpInside)
    topToolView.addSubview(cancelButton)
    cancelButton.layout.add { (make) in
      make.leading().top().bottom().equal(topToolView)
      make.width(44)
    }
    
    confirmButton.setTitle("确定", for: .normal)
    confirmButton.setTitleColor(UIColor(0x1c8bfc), for: .normal)
    confirmButton.titleLabel?.font = Font.system(14)
    confirmButton.addTarget(self, action: #selector(clickConfirm(_:)), for: .touchUpInside)
    topToolView.addSubview(confirmButton)
    confirmButton.layout.add { (make) in
      make.trailing().top().bottom().equal(topToolView)
      make.width(44)
    }
    
    titleLabel.text = "请选择日期"
    titleLabel.font = Font.system(12)
    titleLabel.textAlignment = .center
    titleLabel.textColor = UIColor(0xbbc3d1)
    topToolView.addSubview(titleLabel)
    titleLabel.layout.add { (make) in
      make.leading(10).equal(cancelButton).trailing()
      make.trailing(-10).equal(confirmButton).leading()
      make.top().bottom().equal(topToolView)
    }
    
    let lineView = UIView()
    lineView.backgroundColor = UIColor(0xeeeeee)
    topToolView.addSubview(lineView)
    lineView.layout.add { (make) in
      make.leading().trailing().top().equal(topToolView)
      make.height(0.5)
    }
    
  }
  
}

// MARK: - Action
private extension DatePickerViewController {
  
  @objc func clickCancel(_ sender: Any) {
    
    dismiss(animated: true, completion: nil)
  }
  
  @objc func clickConfirm(_ sender: Any) {
    
    switch mode {
    case .dateAndTime, .countDownTimer:
      
      completionHandle?(systemDatePickerView.date, dateFormatter.string(from: systemDatePickerView.date))
      
    default:
      
      completionHandle?(date, dateFormatter.string(from: date))
    }
    completionHandle = nil
    dismiss(animated: true, completion: nil)
  }
  
}

// MARK: - Utiltiy
private extension DatePickerViewController {
  
  func dateComponents(from date: Date) -> DateComponents {
    
    return Calendar.current.dateComponents(Set(sortedCalendarComponents), from: date)
  }
  
  func date(from dateComponents: DateComponents) -> Date? {
    
    return Calendar.current.date(from: dateComponents)
  }
  
  func set(_ date: Date, animated: Bool) {
    
    /// Date与DateComponents进行同步
    dateComponents = dateComponents(from: date)
    self.date = self.date(from: dateComponents) ?? Date()
    
    customizeDatePickerView.reloadAllComponents()
    
    /// 自定义选择视图选中对应日期时间的行
    sortedCalendarComponents.enumerated().forEach({ (index, mode) in
      
      switch mode {
      case .year: customizeDatePickerView.selectRow((dateComponents.year ?? 1) - 1, inComponent: index, animated: animated)
      case .month: customizeDatePickerView.selectRow((dateComponents.month ?? 1) - 1, inComponent: index, animated: animated)
      case .day: customizeDatePickerView.selectRow((dateComponents.day ?? 1) - 1, inComponent: index, animated: animated)
      case .hour: customizeDatePickerView.selectRow((dateComponents.hour ?? 0), inComponent: index, animated: animated)
      case .minute: customizeDatePickerView.selectRow((dateComponents.minute ?? 0), inComponent: index, animated: animated)
      case .second: customizeDatePickerView.selectRow((dateComponents.second ?? 0), inComponent: index, animated: animated)
      default: break
      }
    })
    
    systemDatePickerView.date = self.date
  }
  
  var dayCount: Int {
    
    var dateComponents = Calendar.current.dateComponents(Set(sortedCalendarComponents), from: Date())
    dateComponents.year = self.dateComponents.year
    dateComponents.month = self.dateComponents.month
    
    guard let date = Calendar.current.date(from: dateComponents) else { return 0 }
    return Calendar.current.range(of: .day, in: .month, for: date)?.count ?? 0
  }
  
}

// MARK: - UIPickerViewDelegate
extension DatePickerViewController: UIPickerViewDelegate {
  
  public func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
    
    let width = pickerView.bounds.width
    
    if Set(sortedCalendarComponents).contains(.year) == true && component == 0 {
      
      return (width * 1.2) / CGFloat(sortedCalendarComponents.count)
    }
    
    return (width * 0.8) / CGFloat(sortedCalendarComponents.count)
  }
  
  public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    
    let mode = sortedCalendarComponents[component]
    
    switch mode {
    case .year: dateComponents.year = row + 1
      
    case .month: dateComponents.month = row + 1
      
    case .day: dateComponents.day = row + 1
      
    case .hour: dateComponents.hour = row
      
    case .minute: dateComponents.minute = row
      
    case .second: dateComponents.second = row
      
    default: break
    }
    
    /// 保存选中的日期时间
    date = Calendar.current.date(from: dateComponents) ?? Date()
    
    /// 如果选中的日期比设置的可选的最小日期小，则自动滑动到最小日期
    if let minimumDate = minimumDate, date < minimumDate {
      
      set(minimumDate, animated: true)
      return
    }
    
    /// 如果选中的日期比设置的可选的最大日期大，则自动滑动到最大日期
    if let maximumDate = maximumDate, date > maximumDate {
      
      set(maximumDate, animated: true)
      return
    }
    
    set(date, animated: true)
  }
  
  public func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
    
    let mode = sortedCalendarComponents[component]
    var dateComponents = self.dateComponents
    
    let text: String
    switch mode {
    case .year:
      
      text = String(format: "%04d年", row + 1)
      dateComponents.year = row + 1
    case .month:
      
      text = String(format: "%02d月", row + 1)
      dateComponents.month = row + 1
      
    case .day:
      
      text = String(format: "%02d日", row + 1)
      dateComponents.day = row + 1
      
    case .hour:
      
      text = String(format: "%02d时", row)
      dateComponents.hour = row
      
    case .minute:
      
      text = String(format: "%02d分", row)
      dateComponents.minute = row
      
    case .second:
      
      text = String(format: "%02d秒", row)
      dateComponents.second = row
      
    default: return nil
    }
    
    guard let date = date(from: dateComponents) else { return nil }
    
    var textFont: UIFont = Font.pingFangSCSemibold(9)
    var textColor: UIColor = UIColor(0x333333)
    
    if let minimumDate = minimumDate, date < minimumDate {
      
      textColor = UIColor(0xaaaaaa)
      textFont = Font.pingFangSCLight(9)
    }
    
    if let maximumDate = maximumDate, date > maximumDate {
      
      textColor = UIColor(0xaaaaaa)
      textFont = Font.pingFangSCLight(9)
    }
    
    return NSAttributedString(string: text, attributes: [.font: textFont, .foregroundColor: textColor])
  }
  
}

// MARK: - UIPickerViewDataSource
extension DatePickerViewController: UIPickerViewDataSource {
  
  public func numberOfComponents(in pickerView: UIPickerView) -> Int {
    
    return sortedCalendarComponents.count
  }
  
  public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    
    let mode = sortedCalendarComponents[component]
    
    switch mode {
    case .year: return 10000
    case .month: return 12
    case .day: return dayCount
    case .hour: return 24
    case .minute: return 60
    case .second: return 60
    default: return 0
    }
  }
  
}
