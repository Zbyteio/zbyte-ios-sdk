//
//  ZByteView.swift
//  ZByteSDK
//
//  Created by Hardik Mehta on 09/06/22.
//

import Foundation
import UIKit
import WebKit

fileprivate class ZByteViewConfiguration
{
    static let urlStr = "https://app.zbyte.io/"
}

fileprivate class ZByteLoaderView:UIView
{
    let activityView:UIActivityIndicatorView = UIActivityIndicatorView()
    
    override init(frame: CGRect) {
        super.init(frame: frame);
        setUp()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder);
        setUp()
    }
    private func setUp()
    {
        self.backgroundColor = .secondarySystemBackground
        self.addSubview(activityView);
        
        activityView.translatesAutoresizingMaskIntoConstraints = false
        activityView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true;
        activityView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true;
        
    }
    func showLoader()
    {
        activityView.startAnimating();
        activityView.isHidden = false;
        self.isHidden = false;
    }
    func hideLoader()
    {
        activityView.stopAnimating();
        activityView.isHidden = true;
        self.isHidden = true;
    }

}
public class ZByteView:UIView,WKNavigationDelegate
{
    private var webview:WKWebView = WKWebView();
    private var loaderView:ZByteLoaderView = ZByteLoaderView()
    
    override init(frame: CGRect) {
        super.init(frame: frame);
        setUp()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder);
        setUp()
    }
    
    private func setUp()
    {
        let webConfiguration = WKWebViewConfiguration()
        webConfiguration.applicationNameForUserAgent = "Version/8.0.2 Safari/600.2.5"
        webview = WKWebView(frame: .zero, configuration: webConfiguration)
        webview.navigationDelegate = self;
        webview.backgroundColor = .clear

        self.addSubview(webview);
        self.addSubview(loaderView);
        
        
        
        webview.translatesAutoresizingMaskIntoConstraints = false
        webview.topAnchor.constraint(equalTo: self.topAnchor).isActive = true;
        webview.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true;
        webview.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true;
        webview.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true;
        
        loaderView.translatesAutoresizingMaskIntoConstraints = false
        loaderView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true;
        loaderView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true;
        loaderView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true;
        loaderView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true;
        

        self.loadLoadURL()
        
    }
    @objc private func loadLoadURL()
    {
        loaderView.showLoader();
        webview.load(URLRequest(url: URL(string: ZByteViewConfiguration.urlStr)!));
    }
    
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!)
    {
        loaderView.hideLoader();
        print("loaded")
    }
    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        
        loaderView.hideLoader();
        print("fail to load");
    }
    
}
