//
//  StarRatingView.swift
//  ComponentKit
//
//  Created by William Lee on 2018/12/10.
//  Copyright © 2018 Hiu. All rights reserved.
//

import UIKit

public protocol StarRatingViewDelegate: class {
  
  func scoreDidChanded(_ sender: Float)
}

public class StarRatingView: UIView {
  
  public weak var delegate: StarRatingViewDelegate?
  
  private let slider = UISlider()
  
  // 当前分数
  public var currentScore: Float = 0.0 {
    
    didSet {
      
      self.slider.setValue(Float(self.currentScore), animated: true)
      
      guard self.allowFloatScore else {
        
        self.showWholeStar()
        
        return
      }
      self.showHalfStar()
    }
  }
  
  // 默认最大分数
  private var maxCount: Int = 5
  // 高亮图片集合
  private var seletedStars: [UIImageView] = []
  // 普通图片集合
  private var normalStars: [UIImageView] = []
  // 半星图片集合
  private var halfStars: [UIImageView] = []
  
  // 星星的size
  private var starSize: CGSize = CGSize(width: 20, height: 20)
  // 星星的间隔
  private var space: CGFloat = 7.0
  //是否允许滑动评分
  private var allowScorll: Bool = true
  //是否允许点击评分
  private var allowTouch: Bool = true
  //是否允许半星评分
  private var allowFloatScore: Bool = false
  
  public init(maxCount: Int = 5,
              currentScore: Float = 0.0,
              starSize: CGSize = .zero,
              space: CGFloat = 0.0,
              allowScorll: Bool = true,
              allowTouch: Bool = true,
              allowFloatScore: Bool = false) {
    
    super.init(frame: .zero)
    self.maxCount = maxCount
    self.currentScore = currentScore
    self.starSize = starSize
    self.space = space
    self.allowTouch = allowTouch
    self.allowScorll = allowScorll
    self.allowFloatScore = allowFloatScore
    self.setupSubViews()
  }
  
  required public init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  
}

//MARK: setup
private extension StarRatingView {
  
  func showHalfStar() {
    
    //允许半个星星的
    let newVaule = lroundf(self.slider.value)
    
    let numberOfAll = Int(self.slider.value)
    
    for index in 0 ..< self.seletedStars.count {
      
      let selectedIamge = self.seletedStars[index]
      
      if index < numberOfAll {
        
        selectedIamge.isHidden = false
        
      }else {
        
        selectedIamge.isHidden = true
      }
    }
    
    if Float(newVaule) > self.slider.value { //就是显示半个星星
      
      
      for index in 0 ..< self.halfStars.count {
        
        let  halfImage = self.halfStars[index]
        
        if index == numberOfAll {
          
          halfImage.isHidden = false
        }else
        {
          halfImage.isHidden = true
        }
        
      }
    }
    else
    {
      self.halfStars.forEach { (imageView) in
        
        imageView.isHidden = true
      }
    }
  }
  
  
  func showWholeStar() {
    
    //整个星星的
    let value = ceil(self.slider.value)
    
    for index in 0 ..< self.seletedStars.count {
      
      let imageView = self.seletedStars[index]
      
      if index  < Int(value) {
        
        imageView.isHidden = false
        
      }else {
        
        imageView.isHidden = true
      }
      
    }
  }
  
  @objc func sliderValueChaned(_ sender: Any)  {
    
    if self.allowFloatScore {
      
      self.showHalfStar()
      
    } else {
      
      self.showWholeStar()
    }
    self.delegate?.scoreDidChanded(ceil(self.slider.value))
  }
  
  
  @objc func sliderOnTap(_ sender: UITapGestureRecognizer) {
    
    let touchPoint = sender.location(in: self.slider)
    let value = (self.slider.maximumValue - self.slider.minimumValue) * Float(touchPoint.x / self.slider.frame.size.width)
    self.slider.setValue(value, animated: true)
    self.slider.sendActions(for: .valueChanged)
    
  }
  
}


//MARK: setup
private extension StarRatingView {
  
  func setupSubViews() {
    
    if self.maxCount == 0 { return }
    
    //设置最大最小值
    self.slider.maximumValue = Float(self.maxCount)
    self.slider.minimumValue = 0.0
    //    self.slider.isContinuous = false
    //设置透明图片
    let thumd = UIImage(named:"shop_slider_clear")?.resizeTo(size: CGSize(width: self.starSize.width, height: self.starSize.height))
    self.slider.setThumbImage(thumd, for: .normal)
    self.slider.setMaximumTrackImage(UIImage(named:"shop_slider_clear"), for: .normal)
    self.slider.setMinimumTrackImage(UIImage(named:"shop_slider_clear"), for: .normal)
    //添加事件
    self.slider.addTarget(self, action: #selector(sliderValueChaned(_:)), for: .valueChanged)
    
    if self.allowTouch {
      let tap = UITapGestureRecognizer.init(target: self, action: #selector(sliderOnTap(_:)))
      self.slider.addGestureRecognizer(tap)
    }
    self.slider.isUserInteractionEnabled = self.allowScorll
    //设置约束
    self.addSubview(self.slider)
    self.slider.layout.add { (make) in
      make.leading().trailing().top().bottom().equal(self)
      make.width((self.starSize.width + self.space) * CGFloat(self.maxCount) - self.space).height(self.starSize.height)
    }
    
    //创建星星图片
    for index in 0 ..< self.maxCount {
      
      let selectedImageView = UIImageView(image: UIImage(named: "shop_star_full"))
      selectedImageView.isHidden = true
      
      let halfImageView = UIImageView(image: UIImage(named: "shop_star_half"))
      halfImageView.isHidden = true
      
      let normalImageView = UIImageView(image: UIImage(named: "shop_star_empty"))
      
      self.addSubview(normalImageView)
      self.addSubview(halfImageView)
      self.addSubview(selectedImageView)
      self.sendSubviewToBack(normalImageView)
      
      self.halfStars.append(halfImageView)
      self.normalStars.append(normalImageView)
      self.seletedStars.append(selectedImageView)
      
      normalImageView.layout.add { (make) in
        
        make.leading(CGFloat(index) * (self.starSize.width + self.space)).equal(self)
        make.centerY().equal(self)
        make.width(self.starSize.width).height(self.starSize.height)
      }
      
      selectedImageView.layout.add { (make) in
        
        make.leading(CGFloat(index) * (self.starSize.width + self.space)).equal(self)
        make.centerY().equal(self)
        make.width(self.starSize.width).height(self.starSize.height)
      }
      
      halfImageView.layout.add { (make) in
        
        make.leading(CGFloat(index) * (self.starSize.width + self.space)).equal(self)
        make.centerY().equal(self)
        make.width(self.starSize.width).height(self.starSize.height)
      }
    }
  }
}


extension UIImage {
  
  //改变图片尺寸
  func resizeTo(size: CGSize) -> UIImage? {
    
    UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale);
    self.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
    guard let reSizeImage = UIGraphicsGetImageFromCurrentImageContext() else { return self }
    UIGraphicsEndImageContext()
    return reSizeImage
    
  }
}

