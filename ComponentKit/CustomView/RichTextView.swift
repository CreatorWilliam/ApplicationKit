//
//  RichTextView.swift
//  ComponentKit
//
//  Created by William Lee on 2019/7/30.
//  Copyright © 2019 William Lee. All rights reserved.
//

import ApplicationKit
import WebKit

public class RichTextView: UIView {
  
  private var webView: WKWebView!
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    setupUI()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
}

// MARK: - Public
public extension RichTextView {
  
  func update(with text: String?) {
    
    var text = text ?? ""
    
    let header = "<head>" + "<meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0, user-scalable=no\"> " + "<style>img{width: 100%; max-width: \(Int(UIScreen.main.bounds.width - 30))px; height:auto;}*{margin:0;padding:0;boder:0}</style>" + "</head>"
    text = "<html>" + "\(header)" + "<body>" + "\(text)" + "</body></html>"
    
    webView.loadHTMLString(text, baseURL: nil)
  }
  
}

// MARK: - Setup
private extension RichTextView {
  
  func setupUI() {
    
    let wkUController = WKUserContentController()
    let wkWebConfig = WKWebViewConfiguration()
    wkWebConfig.userContentController = wkUController
    let jsString = "var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width'); document.getElementsByTagName('head')[0].appendChild(meta); var imgs = document.getElementsByTagName('img');for (var i in imgs){imgs[i].style.maxWidth='100%';imgs[i].style.height='auto';}"
    
    let wkUserScript = WKUserScript(source: jsString, injectionTime: WKUserScriptInjectionTime.atDocumentEnd, forMainFrameOnly: true)
    wkUController.addUserScript(wkUserScript)
    
    webView = WKWebView(frame: .zero, configuration: wkWebConfig)
    //self.webView.scrollView.contentSize = CGSize(width: App.shared.screen.width, height: App.shared.screen.height)
    webView.uiDelegate = self
    webView.navigationDelegate = self
    addSubview(webView)
    webView.layout.add { (make) in
      make.top().bottom().leading().trailing().equal(self)
    }
  }
  
}

// MARK: - WKUIDelegate
extension RichTextView: WKUIDelegate {
  
}

// MARK: - WKNavigationDelegate
extension RichTextView: WKNavigationDelegate {
  
  public func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
    
  }
  
  public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
    
  }
  
  public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
    
    Presenter.showMessage(message: "服务器出小差，请稍后重试")
  }
  
}
