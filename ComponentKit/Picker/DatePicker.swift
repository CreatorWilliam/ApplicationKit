//
//  DatePicker.swift
//  ComponentKit
//
//  Created by William Lee on 30/01/2018.
//  Copyright © 2018 William Lee. All rights reserved.
//

import UIKit

public class DatePicker: NSObject {
  
  private static let shared: DatePicker = DatePicker()
  
  private let datePicker = UIDatePicker()
  private var handle: ((Date) -> Void)?
  
}

public extension DatePicker {
  
  static func open(withHandle handle: @escaping (Date) -> Void) {
    
    DatePicker.shared.handle = handle
    
    let containerController = UIViewController()
    containerController.modalPresentationStyle = .custom
    containerController.view.backgroundColor = UIColor(0x333333).withAlphaComponent(0.6)
    
    let contentView = UIView()
    contentView.backgroundColor = UIColor(0xeeeeee)
    contentView.layer.cornerRadius = 10
    contentView.clipsToBounds = true
    containerController.view.addSubview(contentView)
    
    let titleLabel = UILabel()
    titleLabel.text = "选择日期"
    titleLabel.font = UIFont.boldSystemFont(ofSize: 15)
    titleLabel.textAlignment = .center
    titleLabel.backgroundColor = contentView.backgroundColor
    contentView.addSubview(titleLabel)
    
    let datePicker = DatePicker.shared.datePicker
    datePicker.datePickerMode = .date
    contentView.addSubview(datePicker)
    
    let cancelButton = UIButton(type: .custom)
    cancelButton.setTitle("取消", for: .normal)
    cancelButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
    cancelButton.setTitleColor(.black, for: .normal)
    cancelButton.addTarget(DatePicker.shared, action: #selector(clickCancel(_:)), for: .touchUpInside)
    contentView.addSubview(cancelButton)
    
    let confirmButton = UIButton(type: .custom)
    confirmButton.setTitle("确定", for: .normal)
    confirmButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
    confirmButton.setTitleColor(.black, for: .normal)
    confirmButton.addTarget(DatePicker.shared, action: #selector(clickConfirm(_:)), for: .touchUpInside)
    contentView.addSubview(confirmButton)
    
    contentView.layout.add { (make) in
      
      make.leading(15).trailing(-15).centerY().equal(containerController.view)
    }
    
    titleLabel.layout.add { (make) in
      
      make.top().leading().trailing().equal(contentView)
      make.height(40)
    }
    
    datePicker.layout.add { (make) in
      
      make.top(1).equal(titleLabel).bottom()
      make.leading().trailing().equal(contentView)
      make.height(170)
    }
    
    cancelButton.layout.add { (make) in
      
      make.top(1).equal(datePicker).bottom()
      make.leading().bottom().equal(contentView)
      make.height(45)
    }
    
    confirmButton.layout.add { (make) in
      
      make.top().width().height().equal(cancelButton)
      make.leading(1).equal(cancelButton).trailing()
      make.trailing().equal(contentView)
    }
    
    Presenter.present(containerController, animated: false)
  }
  
  @objc private func clickCancel(_ sender: UIButton) {
    
    DatePicker.shared.datePicker.wm_viewController()?.dismiss(animated: false, completion: {
      
      DatePicker.shared.handle = nil
    })
  }
  
  @objc private func clickConfirm(_ sender: UIButton) {
    
    DatePicker.shared.handle?(DatePicker.shared.datePicker.date)
    
    DatePicker.shared.datePicker.wm_viewController()?.dismiss(animated: false, completion: {
      
      DatePicker.shared.handle = nil
    })
  }
  
}





