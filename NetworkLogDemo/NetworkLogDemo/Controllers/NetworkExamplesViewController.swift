//
//  NetworkExamplesViewController.swift
//  NetworkLogDemo
//
//  Created by Sunil Sharma on 07/04/19.
//  Copyright © 2019 Sunil Sharma. All rights reserved.
//

import UIKit
import WebKit

func printTimeElapsedWhenRunningCode(title:String, operation:()->()) {
    let startTime = CFAbsoluteTimeGetCurrent()
    operation()
    let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
    print("Time elapsed for \(title): \(timeElapsed) s.")
}


@objc
public enum NLRequestProperty: Int, CaseIterable {
    case method
    case httpHeaders
    case httpBody
    case timeoutInterval
    case cellularAccess
    case cachePolicy
    case networkType
    case CookieStatus
    case httpPipeliningStatus
    case requestStartTime
}

@objc
public enum NLResponseMetaData: Int, CaseIterable {
    case statusCode
    case statusDescription
    case mimeType
    case contentLength
    case textEncoding
    case suggestedFileName
    case headers
    case requestStartTime
    case duration
    case redirectUrl
}

@objcMembers
public class NLLogFormatter: NSObject {
    
    public var showRequest: Bool = true
    public var showCurlCmd: Bool = true
    public var showRequestProperties: [NLRequestProperty] = NLRequestProperty.allCases {
        didSet {
            print("hhggh")
            showRequestProperties = Set(showRequestProperties).sorted(by: { (property1, property2) -> Bool in
                return property1.rawValue < property2.rawValue
            })
        }
    }
    public var showResponse: Bool = true
    public var showRequestInResponse: Bool = true
    public var showResponseMetaData: [NLResponseMetaData] = NLResponseMetaData.allCases
    public var logUnreadableResBody: Bool = false
}

class NetworkExamplesViewController: UIViewController {

    @IBOutlet weak var dataHandler: UIButton!
    @IBOutlet weak var dataDelegate: UIButton!
    @IBOutlet weak var downloadHandler: UIButton!
    @IBOutlet weak var downloadDelegate: UIButton!
    @IBOutlet weak var uploadHandler: UIButton!
    @IBOutlet weak var uploadDelegate: UIButton!
    @IBOutlet weak var downloadResume: UIButton!
    @IBOutlet weak var downloadBackground: UIButton!
    @IBOutlet weak var webViewLoad: UIButton!
    var webView = WKWebView(frame: .zero)
    
    var resumeDownloadtask: URLSessionDownloadTask?
    var resumeData: Data?
    
    
    var formatter = NLLogFormatter()
    
    var stored: String = "Hello" {
        willSet {
            print("willSet was called")
            print("stored is now equal to \(self.stored)")
            print("stored will be set to \(newValue)")
        }
        
        didSet {
            stored = stored.capitalized
            print("didSet was called")
            print("stored is now equal to \(self.stored)")
            print("stored was previously set to \(oldValue)")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureViews()
//        WKWebViewConfiguration().setURLSchemeHandler(<#T##urlSchemeHandler: WKURLSchemeHandler?##WKURLSchemeHandler?#>, forURLScheme: <#T##String#>)
        let classes = URLSessionConfiguration.default.protocolClasses
        for cls in classes ?? []{
            let className = cls.description()
            if className == "NFXProtocol" {
                print("Woh")
            }
            print(className)
        }
        
        stored = "welcome"
        formatter.showRequestProperties = [.method, .cellularAccess, .cachePolicy, .CookieStatus, .httpBody, .httpHeaders, .httpPipeliningStatus, .method, .networkType, .timeoutInterval]
        
        printTimeElapsedWhenRunningCode(title: "sort") {
//            for _ in 0...100 {
            formatter.showRequestProperties = [.method, .cellularAccess, .cachePolicy, .CookieStatus, .httpBody, .httpHeaders, .httpPipeliningStatus, .method, .networkType, .timeoutInterval]
            stored = "welcomuouuoiu"
//            }
        }
        stored = "welcomuouo"
        
        printTimeElapsedWhenRunningCode(title: "sorto") {
            //            for _ in 0...100 {
            //            formatter.showRequestProperties = [.method, .cellularAccess, .cachePolicy, .CookieStatus, .httpBody, .httpHeaders, .httpPipeliningStatus, .method, .networkType, .timeoutInterval]
            formatter.showRequestProperties.append(contentsOf: NLRequestProperty.allCases)
            //            }
        }
        
        
        for value in formatter.showRequestProperties {
            print(value.rawValue)
        }
        
    }
    
    func configureViews() {
        let buttonList = [dataHandler, dataDelegate, downloadHandler, downloadDelegate, uploadHandler, uploadDelegate, downloadResume, downloadBackground, webViewLoad]
        
        for button in buttonList {
            button?.backgroundColor = .white
            button?.titleLabel?.numberOfLines = 0
            button?.titleLabel?.textColor = .black
            button?.setTitleColor(UIColor.black, for: .normal)
        }
    }
    
    func getJSONFrom(data: Data?) -> Any? {
        guard let jsonData = data
        else { return nil }
        
        do {
            let jsonObj = try JSONSerialization.jsonObject(with: jsonData, options: .allowFragments)
            return jsonObj
        } catch let error as NSError {
            print(error.debugDescription)
        }
        return nil
    }
    
}

/// URLSession delegates
extension NetworkExamplesViewController: URLSessionDataDelegate {
    
    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
//        print(#function)
    }

    func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
//        print(#function)
    }

    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
//        print(#function)
//        print("ljojojpo")
        completionHandler(.performDefaultHandling, nil)
    }

    func urlSession(_ session: URLSession, taskIsWaitingForConnectivity task: URLSessionTask) {
//        print(#function)
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        print(#function)
//        print(error.debugDescription)
//        print(task.error.debugDescription)
//        print(task.originalRequest.debugDescription)
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didFinishCollecting metrics: URLSessionTaskMetrics) {
//        print(#function)
//        print(metrics.debugDescription)
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, needNewBodyStream completionHandler: @escaping (InputStream?) -> Void) {
//        print(#function)
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, willBeginDelayedRequest request: URLRequest, completionHandler: @escaping (URLSession.DelayedRequestDisposition, URLRequest?) -> Void) {
//        print(#function)
        completionHandler(.continueLoading, request)
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
//        print(#function)
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
//        print(#function)
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse, newRequest request: URLRequest, completionHandler: @escaping (URLRequest?) -> Void) {
//        print(#function)
//        print("New request = \(request.url?.absoluteString ?? "nil")")
        completionHandler(request)
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
//        print(#function)
//        print(self.getJSONFrom(data: data) ?? "")
    }

    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didBecome streamTask: URLSessionStreamTask) {
//        print(#function)
    }

    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didBecome downloadTask: URLSessionDownloadTask) {
//        print(#function)
    }

    private func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
//        print(#function)
//        print(response.debugDescription)
        completionHandler(.allow)
    }

    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, willCacheResponse proposedResponse: CachedURLResponse, completionHandler: @escaping (CachedURLResponse?) -> Void) {
//        print(#function)
        completionHandler(nil)
    }

}

extension NetworkExamplesViewController: URLSessionDownloadDelegate {
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
//        print(#function)
//        print("location \(location.absoluteString)")
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didResumeAtOffset fileOffset: Int64, expectedTotalBytes: Int64) {
//        print(#function)
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
//        print(#function)
    }
    
}

extension NetworkExamplesViewController: URLSessionStreamDelegate {
    
    func urlSession(_ session: URLSession, readClosedFor streamTask: URLSessionStreamTask) {
//        print(#function)
    }
    
    func urlSession(_ session: URLSession, writeClosedFor streamTask: URLSessionStreamTask) {
//        print(#function)
    }
    
    func urlSession(_ session: URLSession, betterRouteDiscoveredFor streamTask: URLSessionStreamTask) {
//        print(#function)
    }
    
    func urlSession(_ session: URLSession, streamTask: URLSessionStreamTask, didBecome inputStream: InputStream, outputStream: OutputStream) {
//        print(#function)
    }
    
}


// Data task
extension NetworkExamplesViewController {
    
    @IBAction func clickedOnDataHandler(_ sender: Any) {
//        print(#function)
        
        let url = URL(string: "https://gorest.co.in/public-api/users?_format=json&access-token=Vy0X23HhPDdgNDNxVocmqv3NIkDTGdK93GfV")!
        
        let session = URLSession.shared
        
        session.dataTask(with: url) { (data, urlResponse, error) in
            print(self.getJSONFrom(data: data) ?? "")
            }.resume()
        
    }
    
    @IBAction func clickedOnDataDelegate(_ sender: Any) {
//        print(#function)
        
        let url = URL(string: "https://httpbin.org/get")!
        
        let configuration = URLSessionConfiguration.ephemeral
        
        let session = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
        
        let task = session.dataTask(with: URLRequest(url: url))
        task.resume()
    }
    
    
}

// Download task
extension NetworkExamplesViewController {
    
    @IBAction func clickedOnDownloadHandler(_ sender: Any) {
        print(#function)
        
        let url = URL(string: "https://source.unsplash.com/collection/400620/250x350")!
        let configuration = URLSessionConfiguration.default
        let session = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
        let task = session.downloadTask(with: url) { (fileUrl, response, error) in
            print("Downloaded file url \(fileUrl?.absoluteString ?? "nil")")
        }
        task.resume()
        
    }
    
    @IBAction func clickedOnDownloadDelegate(_ sender: Any) {
        print(#function)
        let url = URL(string: "https://source.unsplash.com/collection/400620/250x350")!
        let configuration = URLSessionConfiguration.default
        let session = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
        let task = session.downloadTask(with: url)
        task.resume()
    }
    
    @IBAction func clickedOnResumeDownload(_ sender: Any) {
//        print(#function)
        
        guard let button = sender as? UIButton
            else { return }
        print("Button tag \(button.tag)")
        let url = URL(string: "http://file-examples.com/wp-content/uploads/2017/04/file_example_MP4_640_3MG.mp4")!
        let configuration = URLSessionConfiguration.default
        let session = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
        if button.tag == 0 {
            resumeDownloadtask = session.downloadTask(with: url, completionHandler: { (dataUrl, response, error) in
                DispatchQueue.main.async {
                    if let nserror = error as NSError?,
                        let _ = nserror.userInfo[NSURLSessionDownloadTaskResumeData] as? Data{
                    } else {
                        print("Download file url -> \(dataUrl?.absoluteString ?? "no file path found")")
                        button.tag = 0
                        button.setTitle("Download - Resume", for: .normal)
                    }
                }
            })
            resumeDownloadtask?.resume()
            button.tag = 1
            button.setTitle("Pause", for: .normal)
        } else if button.tag == 1 {
            resumeDownloadtask?.cancel(byProducingResumeData: { (resumeData) in
                if resumeData == nil {
                    // Reset data
                    DispatchQueue.main.async {
                        print("Resume is not possible")
                        button.tag = 0
                        button.setTitle("Download - Resume", for: .normal)
                        self.resumeDownloadtask?.cancel()
                        self.resumeDownloadtask = nil
                        self.resumeData = nil
                    }
                } else {
                    DispatchQueue.main.async {
                        self.resumeData = resumeData
                        button.tag = 2
                        button.setTitle("Resume", for: .normal)
                    }
                }
            })
        } else if button.tag == 2 {
            button.setTitle("Downloading...", for: .normal)
//            print("Resume url = \(session.)")
            resumeDownloadtask = session.downloadTask(withResumeData: resumeData!, completionHandler: { (dataUrl, response, error) in
                
                DispatchQueue.main.async {
                    print("Download - Resume: file url -> \(dataUrl?.absoluteString ?? "no file path")")
                    button.tag = 0
                    button.setTitle("Download - Resume", for: .normal)
                }
                self.resumeData = nil
            })
            resumeDownloadtask?.resume()
        }
        
    }
    
    @IBAction func clickedOnBackgroundDownload(_ sender: Any) {
//        print(#function)
        
        let url = URL(string: "http://doanarae.com/doanarae/8880-5k-desktop-wallpaper_23842.jpg")!
        let configuration = URLSessionConfiguration.background(withIdentifier: "com.\(UUID().uuidString)")
        let session = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
        let task = session.downloadTask(with: url)
        task.resume()
        
    }
    
    @IBAction func clickedOnWebView(_ sender: Any) {
        guard let button = sender as? UIButton else { return }
        webView.removeFromSuperview()
        webView = WKWebView(frame: CGRect(x: 20, y: button.frame.maxY + 10, width: self.view.frame.width - 40, height: 300))
        webView.backgroundColor = UIColor.orange
        self.view.addSubview(webView)
//        webView.loadRequest(URLRequest(url: URL(string: "https://source.unsplash.com/collection/400620/250x350")!))
        webView.load(URLRequest(url: URL(string: "https://source.unsplash.com/collection/400620/250x350")!))
        
    }
    
}

// Upload task
extension NetworkExamplesViewController {
    
    @IBAction func clickedOnUploadHandler(_ sender: Any) {
//        print(#function)
        
        let url = URL(string: "https://httpbin.org/post")!
        let uploadURLRequest = URLRequest(url: url)
        let configuration = URLSessionConfiguration.default
        let session = URLSession(configuration: configuration)
        
        let uploadDict: [String: String] = [
            "Mercedes": "Lewis Hamilton",
            "Ferrari": "Sebastian Vettel",
            "RedBull": "Daniel Ricciardo"
        ]
        
        let uploadData = try? JSONEncoder().encode(uploadDict)
        
        guard let data = uploadData
        else {
            print("Unable to create upload data")
            return
        }
        
        let uploadTask = session.uploadTask(with: uploadURLRequest, from: data) { (receivedData, response, error) in
            print(self.getJSONFrom(data: data) ?? "")
        }
        uploadTask.resume()
    }
    
    @IBAction func clickedOnUploadDelegate(_ sender: Any) {
//        print(#function)
        
        let url = URL(string: "https://httpbin.org/post")!
        let uploadURLRequest = URLRequest(url: url)
        let configuration = URLSessionConfiguration.default
        let session = URLSession(configuration: configuration)
        
        let uploadDict: [String: String] = [
            "Mercedes": "Lewis Hamilton",
            "Ferrari": "Sebastian Vettel",
            "RedBull": "Daniel Ricciardo"
        ]
        
        
        let uploadData = try? JSONEncoder().encode(uploadDict)
        
        guard let data = uploadData
            else {
                print("Unable to create upload data")
                return
        }
        
        let uploadTask = session.uploadTask(with: uploadURLRequest, from: data)
        uploadTask.resume()
    }
}
