//
//  LocationPicker.swift
//  ComponentKit
//
//  Created by William Lee on 17/1/2018.
//  Copyright © 2018 William Lee. All rights reserved.
//

import UIKit

public class LocationPicker: UIViewController {
  
  private let titleLabel: UILabel = UILabel()
  private let closeButton: UIButton = UIButton(type: .custom)
  private let provinceActionButton: UIButton = UIButton(type: .custom)
  private let cityActionButton: UIButton = UIButton(type: .custom)
  private let districtActionButton: UIButton = UIButton(type: .custom)
  private let tableView: UITableView = UITableView(frame: .zero, style: .grouped)
  private let whiteBackgroundView: UIView = UIView()
  private let contentView: UIView = UIView()

  private let cell: ReuseItem = ReuseItem(UITableViewCell.self, "Cell")
  
  /// 用于记录当前选择区域的层级
  private var state: SelectState = .province {
    
    didSet {
      
      self.updateDataSource()
    }
  }
  /// 保存地址信息
  private var location: LocationItem = LocationItem() {
    
    didSet {
      
      self.updateActionButtons()
    }
  }
  
  private var plist: [[String : Any]] = []
  private var area: [String: [[String: [[String: String]]]]] = [:]
  private var titles: [String] = []
  
  
  private var completionHandle: ((_ location: LocationItem) -> Void)?
  
  public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    
    self.modalPresentationStyle = .custom
  }
  
  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    
    self.setupView()
    self.setupLayout()
    
    self.loadData()
  }
  
  public override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    self.contentView.layout.update({ (make) in
      
      make.bottom().equal(self.view)
    })
    
    UIView.animate(withDuration: 0.3, animations: {
      
      self.view.layoutIfNeeded()
      
    })
  }
  
//  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//
//    for touch in touches {
//
//      guard touch.view == self.view else { continue }
//
//      self.dismiss(animated: false) { }
//      return
//    }
//
//  }
  
}

// MARK: - Public
public extension LocationPicker {
  
  static func open(with location: LocationItem, andHandle handle: @escaping (LocationItem) -> Void) {
    
    let picker = LocationPicker()
    picker.location = location
    picker.completionHandle = handle
    Presenter.present(picker, animated: false)
  }
  
}

// MARK: - UITableViewDelegate
extension LocationPicker: UITableViewDelegate {
  
  public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
    tableView.deselectRow(at: indexPath, animated: true)
    
    switch self.state {

    case .province:
      
      self.location.province = self.titles[indexPath.row]
      self.location.city = ""
      self.location.district = ""
      self.state = .city
      self.scrollToTop()
      
    case .city:
      
      self.location.city = self.titles[indexPath.row]
      self.location.district = ""
      self.state = .district
      self.scrollToTop()
      
    default:
      
      self.location.district = self.titles[indexPath.row]
      self.clickClose(self.closeButton)

    }
    
    self.updateActionButtons()
  }
  
  public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    
    return 0.01
  }
  
  public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    
    return 0.01
  }
  
}

// MARK: - UITableViewDataSource
extension LocationPicker: UITableViewDataSource {
  
  public func numberOfSections(in tableView: UITableView) -> Int {
    
    return 1
  }
  
  public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
    return self.titles.count
  }
  
  public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    let cell = tableView.dequeueReusableCell(withIdentifier: self.cell.id, for: indexPath)
    
    cell.textLabel?.font = UIFont.systemFont(ofSize: 14)
    cell.textLabel?.textColor = UIColor(0x333333)
    cell.textLabel?.text = self.titles[indexPath.row]
    
    return cell
  }
  
}

// MARK: - Setup
private extension LocationPicker {
  
  enum SelectState {
    
    case province
    case city
    case district
  }
  
  func setupView() -> Void {

    
    self.view.backgroundColor = UIColor.black.withAlphaComponent(0.3)
    
    // ContentView
    self.contentView.backgroundColor = .white
    
    // Province,City,District backgroundView
    self.whiteBackgroundView.backgroundColor = .white
    
    // Title
    self.titleLabel.text = "当前城市"
    self.titleLabel.textColor = UIColor(0x33333)
    self.titleLabel.font = Font.system(15)
    self.titleLabel.textAlignment = .center
    self.titleLabel.backgroundColor = .white
    
    // Close
    self.closeButton.setImage(UIImage(named: "close_gray"), for: .normal)
    self.closeButton.contentEdgeInsets = UIEdgeInsets(top: 5, left: 15, bottom: 5, right: 15)
    self.closeButton.addTarget(self, action: #selector(clickClose(_:)), for: .touchUpInside)
    
    // Province
    self.setupCustom(self.provinceActionButton)
    self.provinceActionButton.addTarget(self, action: #selector(clickProvince(_:)), for: .touchUpInside)
    // City
    self.setupCustom(self.cityActionButton)
    self.cityActionButton.addTarget(self, action: #selector(clickCity(_:)), for: .touchUpInside)
    // District
    self.setupCustom(self.districtActionButton)
    self.districtActionButton.addTarget(self, action: #selector(clickDistrict(_:)), for: .touchUpInside)
    
    // TableView
    self.tableView.delegate = self
    self.tableView.dataSource = self
    self.tableView.rowHeight = 33
    self.tableView.estimatedSectionHeaderHeight = 0
    self.tableView.estimatedSectionFooterHeight = 0
    self.tableView.backgroundColor = .white
    self.tableView.separatorColor = .white
    self.tableView.register(cells: [self.cell])
    
    
    self.contentView.addSubview(self.whiteBackgroundView)
    self.contentView.addSubview(self.titleLabel)
    self.contentView.addSubview(self.closeButton)
    self.contentView.addSubview(self.provinceActionButton)
    self.contentView.addSubview(self.cityActionButton)
    self.contentView.addSubview(self.districtActionButton)
    self.contentView.addSubview(self.tableView)
    self.view.addSubview(self.contentView)
  }
  
  func setupLayout() -> Void {
    
    self.contentView.layout.add { (make) in
      
      make.leading().trailing().bottom(280).equal(self.view)
      make.height(280)
    }
    
    self.whiteBackgroundView.layout.add { (make) in
      
      make.top(1).equal(self.titleLabel).bottom()
      make.leading().trailing().equal(self.contentView)
      make.height(40)
    }

    self.titleLabel.layout.add { (make) in
      
      make.top().leading().trailing().equal(self.contentView)
      make.height(40)
    }
    
    self.closeButton.layout.add { (make) in
      
      make.centerY().trailing().equal(self.titleLabel)
    }
    
    self.provinceActionButton.layout.add { (make) in
      
      make.leading(15).centerY().equal(self.whiteBackgroundView)
    }
    
    self.cityActionButton.layout.add { (make) in
      
      make.leading(25).equal(self.provinceActionButton).trailing()
      make.centerY().equal(self.whiteBackgroundView)
    }
    
    self.districtActionButton.layout.add { (make) in
      
      make.leading(25).equal(self.cityActionButton).trailing()
      make.centerY().equal(self.whiteBackgroundView)
    }
    
    self.tableView.layout.add { (make) in
      
      make.top(1).equal(self.whiteBackgroundView).bottom()
      make.leading().trailing().bottom().equal(self.contentView)
    }
    
    self.view.layoutIfNeeded()
  }
  
  func setupCustom(_ button: UIButton) {
    
    button.contentEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
    button.titleLabel?.font = UIFont.systemFont(ofSize: 13)
    button.setTitleColor(UIColor(0x999999), for: .normal)
    button.setTitleColor(UIColor(0x333333), for: .selected)
    
  }
  
}

// MARK: - Action
private extension LocationPicker {
  
  @objc func clickClose(_ sender: UIButton) {
    
    self.completionHandle?(self.location)
    
    self.dismiss(animated: false) {
      
    }
  }
  
  @objc func clickProvince(_ sender: UIButton) {
    
    self.provinceActionButton.isSelected = true
    self.cityActionButton.isSelected = false
    self.districtActionButton.isSelected = false
    self.state = .province
    self.updateDataSource()
  }
  
  @objc func clickCity(_ sender: UIButton) {
    
    self.provinceActionButton.isSelected = false
    self.cityActionButton.isSelected = true
    self.districtActionButton.isSelected = false
    self.state = .city
    self.updateDataSource()
  }
  
  @objc func clickDistrict(_ sender: UIButton) {
    
    self.provinceActionButton.isSelected = false
    self.cityActionButton.isSelected = false
    self.districtActionButton.isSelected = true
    self.state = .district
    self.updateDataSource()
  }
  
}

// MARK: - Utility
private extension LocationPicker {
  
  func loadData() {
    
    guard let path = Bundle.main.path(forResource: "area", ofType: "plist") else { return }
    guard let data = try? Data(contentsOf: URL(fileURLWithPath: path)) else { return }
    guard let any = try? PropertyListSerialization.propertyList(from: data, options: PropertyListSerialization.ReadOptions.mutableContainersAndLeaves, format: nil) else { return }
    guard let plist = any as? [[String : Any]] else { return }
    
    self.plist = plist
    
    self.updateDataSource()
  }
  
  func updateActionButtons() {
    
    self.provinceActionButton.setTitle(self.location.province, for: .normal)
    self.cityActionButton.setTitle(self.location.city, for: .normal)
    self.districtActionButton.setTitle(self.location.district, for: .normal)
    
    self.provinceActionButton.isEnabled = (self.location.province != "")
    self.cityActionButton.isEnabled = (self.location.city != "")
    self.districtActionButton.isEnabled = (self.location.district != "")
    
    switch self.state {
    case .province:
      
      self.provinceActionButton.isSelected = true
      self.cityActionButton.isSelected = false
      self.districtActionButton.isSelected = false
      
    case .city:
      
      self.provinceActionButton.isSelected = false
      self.cityActionButton.isSelected = true
      self.districtActionButton.isSelected = false
      
    case .district:
      
      self.provinceActionButton.isSelected = false
      self.cityActionButton.isSelected = false
      self.districtActionButton.isSelected = true
    }
  }
  
  func updateDataSource() {
    
    switch self.state {
    case .province:
      
      let provinces = self.plist.map { $0["state"] as? String ?? "" }
      self.titles = provinces
      
    case .city:
      
      guard let cities = self.plist.filter({  $0["state"] as? String ?? "" == self.location.province }).first?["cities"] as? [[String : Any]] else { break }
      self.titles = cities.map({ $0["city"] as? String ?? "" })
      
    case .district:
      
      guard let cities = self.plist.filter({  $0["state"] as? String ?? "" == self.location.province }).first?["cities"] as? [[String : Any]] else { break }
      guard let districts = cities.filter({ $0["city"] as? String ?? "" == self.location.city }).first?["areas"] as? [String] else { break }
      self.titles = districts
    }
    
    self.tableView.reloadData()
  }
  
  func scrollToTop() {
    
    let count = (0 ..< self.tableView.numberOfSections).map({ self.tableView.numberOfRows(inSection: $0) }).reduce(0, { $0 + $1 })
    if count < 1 {
      
      self.clickClose(self.closeButton)
      return
    }
    guard count > 0 else { return }
    self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
  }
  
}







