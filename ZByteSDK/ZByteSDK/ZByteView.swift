//
//  ZbyteView.swift
//  ZbyteSDK
//
//  Created by Hardik Mehta on 09/06/22.
//

import Foundation
import UIKit
import WebKit
import UserNotifications


public class ZbyteSDKManager:NSObject
{
    static var dLSurveyId = ""
    static var dLNftId = ""
    
    public static func handlePushNotificationTap(response: UNNotificationResponse)
    {
        let userInfo = response.notification.request.content.userInfo
       print(userInfo);
           var surveyID = "";
           var nftId = "";
           
           if let tSurveyId = userInfo["survey_id"] as? String
           {
               surveyID = tSurveyId;
           }
           if let tNftId = userInfo["nftId"] as? String
           {
               nftId = tNftId;
           }
        
            dLSurveyId = surveyID;
            dLNftId = nftId;
        
           print("DEBUG : Payload received");
           print("DEBUG : nftId=\(nftId),surveyID=\(surveyID)");
    }
    public static func setWebViewBaseURL(urlStr:String)
    {
        UserDefaults.standard.setValue(urlStr, forKey: "zbyte_webBaseUrl");
        UserDefaults.standard.synchronize();
    }
    public static func setAPIBaseURL(urlStr:String)
    {
        UserDefaults.standard.setValue(urlStr, forKey: "zbyte_apiBaseUrl");
        UserDefaults.standard.synchronize();
    }
    public static func getWebViewBaseURL()->String
    {
        if let urlStr = UserDefaults.standard.value(forKey: "zbyte_webBaseUrl") as? String
        {
            return urlStr;
        }
        else
        {
            return ZbyteViewConfiguration.WEB_URL_TEST
        }
    }
    public static func getAPIBaseURL()->String
    {
        if let urlStr = UserDefaults.standard.value(forKey: "zbyte_apiBaseUrl") as? String
        {
            return urlStr;
        }
        else
        {
            return ZbyteViewConfiguration.API_URL_TEST
        }
    }
    public static func getFirebaseDocumentName()->String
    {
        let webURL = self.getWebViewBaseURL();
        
        var envinorStr = webURL.slice(from: "//", to: ".");
        envinorStr = "user_\(envinorStr!)";
        return envinorStr!;
    }
}

//configuration class
fileprivate class ZbyteViewConfiguration
{
    static let userAgent = "Version/8.0.2 Safari/600.2.5"
    static let WEB_URL_PROD="https://app.zbyte.io/"
    static let WEB_URL_TEST="https://appdev.zbyte.io/"
    static let API_URL_PROD="https://auth.zbyte.io/"
    static let API_URL_TEST="https://authdev.zbyte.io/"
    
    
    static var urlStr:String {
        get {
            return ZbyteSDKManager.getWebViewBaseURL();
        }
    }
    static var apiUrlStr:String {
        get {
            return ZbyteSDKManager.getAPIBaseURL();
        }
        
    }
}


//Custom loader view
fileprivate class ZbyteLoaderView:UIView
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

//ZbyteView Protocols
public protocol ZbyteViewDelegate {
    
    func onUserInfoReceived(data: String)
//    optional func onAccessTokenReceived(token:String)
    
}


//ZbyteView Custom class
public class ZbyteView:UIView, WKNavigationDelegate, WKUIDelegate
{
    private var webview:WKWebView = WKWebView();
    private var loaderView:ZbyteLoaderView = ZbyteLoaderView()
    private var userId:String? = nil;
    private var accessToken:String? = nil;
    public var delegate:ZbyteViewDelegate? = nil;
    
    //initialising
    override init(frame: CGRect) {
        super.init(frame: frame);
        setUp()
    }
    
    //initialising
    required init?(coder: NSCoder) {
        super.init(coder: coder);
        setUp()
    }
    
    //Set Up UI
    private func setUp()
    {
        //setting up configuration for webview
        let webConfiguration = WKWebViewConfiguration()
        webConfiguration.applicationNameForUserAgent = ZbyteViewConfiguration.userAgent
        
        //setting up webview
        webview = WKWebView(frame: .zero, configuration: webConfiguration)
        webview.navigationDelegate = self;
        webview.uiDelegate = self;
        webview.backgroundColor = .clear
        self.addSubview(webview);
        
        
        //setting up loader view
        self.addSubview(loaderView);
        
        
        //Setting up constraints
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
        
        //Load url
        self.loadLoadURL()
        fetchUserId();
    }
    
    //web url request
    @objc private func loadLoadURL()
    {
        //show loader
        loaderView.showLoader();
        
        //Perform request
        loadURLRequestWithURL(url: URL(string: ZbyteViewConfiguration.urlStr)!)
        
    }
    private func loadURLRequestWithURL(url:URL)
    {
        webview.load(URLRequest(url:url));
    }
    
    //web url request finish success
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!)
    {
        //
        loaderView.hideLoader();
    }
    
    @objc func fetchUserId()
    {
        if let url = webview.url
        {
            let urlStr = url.absoluteString
            
            if(urlStr == "\(ZbyteViewConfiguration.urlStr)mynft")
            {
                
                print("url -> \(urlStr)")
                
                let scriptNew="localStorage.getItem(\"account\");";
                webview.evaluateJavaScript(scriptNew) { (reply, error) in
                    
                    if let replyStr = reply as? String
                    {
                        print("Received");
                        print("output is : \n")
                        print(reply);
                        print(error);
                        
                        if let jsonDict = replyStr.toJSON() as? NSDictionary
                        {
                            if let connectedAccount = jsonDict.value(forKey: "connectedAccount") as? NSDictionary
                            {
                                if let loginnOptions = connectedAccount.value(forKey: "loginOptions") as? NSDictionary
                                {
                                    if let userIdReceived = loginnOptions.value(forKey: "id") as? Int64
                                    {
                                      //  self.fetchToken();
                                        self.userId = "\(userIdReceived)";
                                        self.onUserIdReceived();
                                        
                                        if(ZbyteSDKManager.dLNftId != "" && ZbyteSDKManager.dLSurveyId != "")
                                        {
                                            
                                            let urlStr = "\(ZbyteViewConfiguration.urlStr)/mynft?nft_id=\(ZbyteSDKManager.dLNftId)&survey_id=\(ZbyteSDKManager.dLSurveyId)";
                                            self.loadURLRequestWithURL(url: URL(string: urlStr)!)
                                            
                                            ZbyteSDKManager.dLNftId = ""
                                            ZbyteSDKManager.dLSurveyId = ""
                                            
                                            return;
                                        }
                                    }
                                }
                            }
                        }
                        
                    }
                    else
                    {
                        print("error is : \n")
                        print(reply);
                    }
                    
                }
            }
            
        }
        if(self.userId == nil)
        {
            self.perform(#selector(fetchUserId), with: nil, afterDelay: 1.0);
        }
    }
    func onUserIdReceived()
    {
        self.delegate?.onUserInfoReceived(data: self.userId!);
    }
    func fetchToken()
    {
        if(self.accessToken == nil)
        {
            webview.getCookies(for: webview.url!.host) { data in
                
                print("=========================================")
                print("\(self.webview.url!.absoluteString)")
                print(data)
                
                if let tokenDict = data["accessToken"] as? NSDictionary
                {
                    if let value = tokenDict["Value"] as? String
                    {
                        self.accessToken = value;
                        print("Token = \(value)");
                        self.requestForEmailAddress();
                    }
                    
                }
                
            }
        }
        
        
        
        
    }
    func requestForEmailAddress()
    {
        if(self.accessToken != nil && self.userId != nil)
        {
            
            self.callAPI { status, result, errorString in
                
                if(status == true)
                {
                    if let resultRec = result
                    {
                        if let dataDict = resultRec["data"] as? NSDictionary
                        {
                            if let email = dataDict["email"] as? String
                            {
                                DispatchQueue.main.async {
                                    
                                    self.delegate?.onUserInfoReceived(data: email);
                                    
                                }
                                
                            }
                        }
                    }
                    
                }
                print("\(result)");
            }
            
        }
    }
    
    
    func callAPI(completion: @escaping (_ status:Bool,_ result: NSDictionary?, _ errorString:String?) -> Void)
    {
        let mainURL = "\(ZbyteViewConfiguration.apiUrlStr)getUserProfile";
        
        let session = URLSession.shared
        let url = URL(string: mainURL)!
        print("callinng result");
        
        var request = URLRequest(url: url);
        request.httpMethod = "POST";
        
        let parameters = "{\n    \"userId\": \(self.userId!)\n}"
        let postData = parameters.data(using: .utf8)
        
        request.addValue("Bearer \(self.accessToken!)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        request.httpBody = postData
        
        
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            
            print("Got result");
            if error != nil || data == nil {
                print("Client error!")
                completion(false,nil,"Client Error");
                return
            }
            
            //                guard let response = response as? HTTPURLResponse, (200...299).contains(response.statusCode) else {
            //                    print("Server error!")
            //                    completion(false,nil,"Server error!")
            //
            //                    return
            //                }
            
            //            guard let mime = response.mimeType, mime == "application/json" else {
            //                print("Wrong MIME type!")
            //                completion(false,nil)
            //
            //                return
            //            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: []) as! NSDictionary
                
                print("\(json)");
                
                completion(true,json,nil)
                
            } catch {
                completion(false,nil,"Parse error!")
                
                print("JSON error: (error.localizedDescription)")
            }
        }
        
        task.resume()
    }
    
    //web url request finish fail
    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        
        //
        loaderView.hideLoader();
    }
    
}

extension WKWebView {

    private var httpCookieStore: WKHTTPCookieStore  { return WKWebsiteDataStore.default().httpCookieStore }

    func getCookies(for domain: String? = nil, completion: @escaping ([String : Any])->())  {
        var cookieDict = [String : AnyObject]()
        httpCookieStore.getAllCookies { cookies in
            for cookie in cookies {
                if let domain = domain {
                    if cookie.domain.contains(domain) {
                        cookieDict[cookie.name] = cookie.properties as AnyObject?
                    }
                } else {
                    cookieDict[cookie.name] = cookie.properties as AnyObject?
                }
            }
            completion(cookieDict)
        }
    }
}

extension ZbyteView {
    
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        
        webView.loadDiskCookies(for: URL(string: ZbyteViewConfiguration.urlStr)!.host!){
        }
        
        if navigationAction.targetFrame == nil, let url = navigationAction.request.url {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
        decisionHandler(WKNavigationActionPolicy.allow)
    }

    
    public func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        //write cookie for current domain
        webView.writeDiskCookies(for: URL(string: ZbyteViewConfiguration.urlStr)!.host!){
            decisionHandler(.allow)
        }
    }
    public func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        
        if navigationAction.targetFrame == nil {
            webView.load(navigationAction.request)
            loaderView.showLoader()
        }
        return nil
        
    }
    
}

extension WKWebView {
    
    enum PrefKey {
        static let cookie = "cookies"
    }
    
    func writeDiskCookies(for domain: String, completion: @escaping () -> ()) {
        fetchInMemoryCookies(for: domain) { data in
            print("write data", data)
            UserDefaults.standard.setValue(data, forKey: PrefKey.cookie + domain)
            completion();
        }
    }
    
    
    func loadDiskCookies(for domain: String, completion: @escaping () -> ()) {
        if let diskCookie = UserDefaults.standard.dictionary(forKey: (PrefKey.cookie + domain)){
            fetchInMemoryCookies(for: domain) { freshCookie in
                
                let mergedCookie = diskCookie.merging(freshCookie) { (_, new) in new }
                
                for (cookieName, cookieConfig) in mergedCookie {
                    let cookie = cookieConfig as! Dictionary<String, Any>
                    
                    var expire : Any? = nil
                    
                    if let expireTime = cookie["Expires"] as? Double{
                        expire = Date(timeIntervalSinceNow: expireTime)
                    }
                    
                    let newCookie = HTTPCookie(properties: [
                        .domain: cookie["Domain"] as Any,
                        .path: cookie["Path"] as Any,
                        .name: cookie["Name"] as Any,
                        .value: cookie["Value"] as Any,
                        .secure: cookie["Secure"] as Any,
                        .expires: expire as Any
                    ])
                    
                    self.configuration.websiteDataStore.httpCookieStore.setCookie(newCookie!)
                }
                
                completion()
            }
            
        }
        else{
            completion()
        }
    }
    
    func fetchInMemoryCookies(for domain: String, completion: @escaping ([String: Any]) -> ()) {
        var cookieDict = [String: AnyObject]()
        WKWebsiteDataStore.default().httpCookieStore.getAllCookies { (cookies) in
            for cookie in cookies {
                if cookie.domain.contains(domain) {
                    cookieDict[cookie.name] = cookie.properties as AnyObject?
                }
            }
            completion(cookieDict)
        }
    }
    
}
//Extension for JSON
extension String {
    func toJSON() -> Any? {
        guard let data = self.data(using: .utf8, allowLossyConversion: false) else { return nil }
        return try? JSONSerialization.jsonObject(with: data, options: .mutableContainers)
    }
    func slice(from: String, to: String) -> String? {
           return (range(of: from)?.upperBound).flatMap { substringFrom in
               (range(of: to, range: substringFrom..<endIndex)?.lowerBound).map { substringTo in
                   String(self[substringFrom..<substringTo])
               }
           }
       }
}
