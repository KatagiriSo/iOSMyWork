//
//  ViewController.swift
//  WebAppTest
//
//  Created by KatagiriSo on 2018/04/25.
//  Copyright © 2018年 KatagiriSo. All rights reserved.
//

import UIKit
import WebKit

protocol WebViewReceiver : class {
    var webView:WKWebView! {get set}
    var webViewCommandDelegate:WebViewCommandDelegate! {get set}
    var webViewNaviDelegate:WebViewNavigationDelegate! {get set}
    var webViewUIDelegate:WebViewUIDelegate! {get set}
}

protocol WebViewSetUp : WebViewReceiver {
    func setupWebView()
}

protocol WebCommandDelegate {
    func on(command:String, param:[String:String])
}

class ViewController: UIViewController, WebViewReceiver, WebViewSetUp {
    
    var webView:WKWebView!
    var webViewCommandDelegate:WebViewCommandDelegate!
    var webViewNaviDelegate:WebViewNavigationDelegate!
    var webViewUIDelegate:WebViewUIDelegate!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.setupWebView()
        
        WebLoad(webView: self.webView).start(name: "hello")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

class WebViewCommandDelegate : WebCommandDelegate {
    
    var webView:WKWebView
    init(webView:WKWebView) {
        self.webView = webView
    }
    
    func on(command: String, param: [String : String]) {
        print("command \(command)")
        print("param \(param.description)")
        switch command {
        case "login":
            onLogin(email:param["email"], password:param["password"])
        default:
            fatalError()
        }
    }
    
    func onLogin(email:String?, password:String?) {
        
        webView.evaluateJavaScript("message(\"wrong\")") { (res, e) in
            print("res\(String(describing: res))")
            print("error\(e)")
        }
        
        
    }
}

class WebViewNavigationDelegate : NSObject, WKNavigationDelegate {
    var target:WebCommandDelegate
    init(target:WebCommandDelegate) {
        self.target = target
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Swift.Void) {
        
        defer {
            decisionHandler(.allow)
        }
        
        guard let url = navigationAction.request.url else {
            return
        }
        
        if url.scheme == "app" {
//            print("host.." + (url.host ?? ""))
//            print("path..." + url.pathComponents.description)
//            print("query..." + ((url.query?.description) ?? ""))
            guard let command = url.host else {
                return
            }
            
            let querys = URLComponents(url: url, resolvingAgainstBaseURL: true)?.queryItems
            var param = [String:String]()
            querys?.forEach { param[$0.name] = $0.value }
            
            target.on(command: command, param: param)
        }
        
    }
}

class WebViewUIDelegate : NSObject, WKUIDelegate {
    var target:UIViewController
    init(target:UIViewController) {
        self.target = target
    }
}

struct WebLoad {
    let webView:WKWebView
    func start(name:String) {
        guard let path = Bundle.main.path(forResource: name, ofType: "html") else {
            fatalError()            
        }
        
        let url = URL(fileURLWithPath:path)
        let request = URLRequest(url: url)
        webView.load(request)
    }
    
}



extension WebViewSetUp where Self : UIViewController {
    func setupWebView() {
        let config = WKWebViewConfiguration()
        self.webView = WKWebView(frame: self.view.bounds, configuration: config)
        self.view.addSubview(self.webView)
        
        self.webViewCommandDelegate = WebViewCommandDelegate(webView: self.webView)
        self.webViewNaviDelegate = WebViewNavigationDelegate(target: self.webViewCommandDelegate)
        self.webViewUIDelegate = WebViewUIDelegate(target: self)
        
        webView.navigationDelegate = self.webViewNaviDelegate
        webView.uiDelegate = self.webViewUIDelegate
        
        webView.allowsBackForwardNavigationGestures = false
    }
}



