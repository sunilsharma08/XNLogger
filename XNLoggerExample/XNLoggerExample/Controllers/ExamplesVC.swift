//
//  ExamplesVC.swift
//  XNLoggerExample
//
//  Created by Sunil Sharma on 07/04/19.
//  Copyright © 2019 Sunil Sharma. All rights reserved.
//

import UIKit
import WebKit
import XNLogger

class ExamplesVC: UIViewController {

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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureViews()
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

extension String {
    
    func fromBase64() -> String? {
        guard let data = Data(base64Encoded: self)
            else { return nil }
        
        return String(data: data, encoding: .utf8)
    }
    
    func toBase64() -> String {
        return Data(self.utf8).base64EncodedString()
    }
    
    func urlEncoded() -> String {
        return self.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? ""
    }
    
}

extension Data {
    mutating func appendString(_ string: String) {
        let data = string.data(using: String.Encoding.utf8, allowLossyConversion: true)
        append(data!)
    }
}

// Data task
extension ExamplesVC {
    
    func generateBoundaryString() -> String {
        return "Boundary-\(UUID().uuidString)"
    }
    
    func dataUploadBodyWithParameters(_ parameters: [String: Any]?, filename: String, mimetype: String, dataKey: String, data: Data, boundary: String) -> Data {
        var body = Data()
        // encode parameters first
        if parameters != nil {
            for (key, value) in parameters! {
                body.appendString("--\(boundary)\r\n")
                body.appendString("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
                body.appendString("\(value)\r\n")
            }
        }
        
        body.appendString("--\(boundary)\r\n")
        body.appendString("Content-Disposition: form-data; name=\"\(dataKey)\"; filename=\"\(filename)\"\r\n")
        body.appendString("Content-Type: \(mimetype)\r\n\r\n")
        body.append(data)
        body.appendString("\r\n")
        body.appendString("--\(boundary)--\r\n")
        
        return body
    }
    
    func uploadData(_ data: Data, toURL urlString: String, withFileKey fileKey: String, completion: ((_ success: Bool, _ result: Any?) -> Void)?) {
        if let url = URL(string: urlString) {
            // build request
            let boundary = generateBoundaryString()
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
//            request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
//            request.setValue("application/json", forHTTPHeaderField: "Accept")
            
            // build body
            let body = dataUploadBodyWithParameters(nil, filename: "uploadimage.png", mimetype: "image/png", dataKey: fileKey, data: data, boundary: boundary)
            request.httpBody = body
            
            // UIApplication.shared.isNetworkActivityIndicatorVisible = true
            URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) -> Void in
                if data != nil && error == nil {
                    do {
                        let result = try JSONSerialization.jsonObject(with: data!, options: [])
                        DispatchQueue.main.async(execute: { completion?(true, result) })
                    } catch {
                        DispatchQueue.main.async(execute: { completion?(false, nil) })
                    }
                } else { DispatchQueue.main.async(execute: { completion?(false, nil) }) }
                // UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }).resume()
        } else { DispatchQueue.main.async(execute: { completion?(false, nil) }) }
    }

    
    @IBAction func clickedOnDataHandler(_ sender: Any) {
//        print(#function)
        
        let url = URL(string: "https://gorest.co.in/public-api/users?_format=json&access-token=Vy0X23HhPDdgNDNxVocmqv3NIkDTGdK93GfV")!
        
        var urlRequest: URLRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.addValue("alloo", forHTTPHeaderField: "sabji")
        urlRequest.setValue("gjghj", forHTTPHeaderField: "llnlnoln")
        let json: [String: Any] = ["title": "AB'C",
                                   "dict": ["1":"First", "2":"Second"]]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        let dataString = Data(base64Encoded: "{\"u\":\"uiuiui\"}%".toBase64())
        func getJsonObjectFrom(jsonData: Data) throws -> Any {
            if (!JSONSerialization.isValidJSONObject(jsonData)) {
                print("is not a valid json object")
            }
            do {
                let jsonObj = try JSONSerialization.jsonObject(with: jsonData, options: [.allowFragments])
                return jsonObj
            } catch let parseError {
                print("NL: JSON serialization error: \(parseError)")
                throw parseError
            }
        }
        do {
            let test = try getJsonObjectFrom(jsonData: dataString ?? Data())
        }
        catch let error as NSError {
            print("Rtuigug = \(error.localizedDescription)")
        }
        
        var myInt = 77
        var dataNumber = Data(bytes: &myInt,
                             count: MemoryLayout.size(ofValue: myInt))
        urlRequest.httpBody = jsonData
        let session = URLSession.shared
        
        session.dataTask(with: urlRequest) { (data, urlResponse, error) in
            print(self.getJSONFrom(data: data) ?? "")
        }.resume()
//        let url = "http://server/upload"
//        let img = UIImage(named: "water.png") ?? UIImage()
//        let data: Data = img.pngData() ?? Data()
////
//        uploadData(data, toURL: "https://httpbin.org/post", withFileKey: "profileImage", completion: nil)
        
//        uploadImageToServerFromApp(nameOfApi: "https://gorest.co.in/public-api/users?_format=json&access-token=Vy0X23HhPDdgNDNxVocmqv3NIkDTGdK93GfV", uploadedImage: UIImage(named: "water.png") ?? UIImage())
        
    }
    
    @IBAction func clickedOnDataDelegate(_ sender: Any) {
//        print(#function)
        
        let url = URL(string: "https://httpbin.org/get")!
        
        let configuration = URLSessionConfiguration.ephemeral
        
        let session = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
        
        let task = session.dataTask(with: URLRequest(url: url))
        task.resume()
        
//        if let logger = customLogger {
//            NetworkLogger.shared.removeHandlers([logger])
//        }
//        customLogger = nil
//        customLogger = nil
    }
    
    
}

// Download task
extension ExamplesVC {
    
    @IBAction func clickedOnDownloadHandler(_ sender: Any) {
        print(#function)
        
        let url = URL(string: "https://source.unsplash.com/collection/400620/250x350")!
        let configuration = URLSessionConfiguration.default
        let session = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
        let task = session.downloadTask(with: url) { (fileUrl, response, error) in
            print("Downloaded file url \(fileUrl?.absoluteString ?? "nil")")
        }
        task.resume()
        
//        if let viewController = self.storyboard?.instantiateViewController(withIdentifier: "SecondViewController") as? SecondViewController {
//            viewController.controller = self
//            self.navigationController?.pushViewController(viewController, animated: true)
//        }
        
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
extension ExamplesVC {
    
    @IBAction func clickedOnUploadHandler(_ sender: Any) {
//        print(#function)
        
        let url = URL(string: "https://httpbin.org/post")!
        var uploadURLRequest = URLRequest(url: url)
        uploadURLRequest.httpMethod = "POST"
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
        let jsonData = try? JSONSerialization.data(withJSONObject: uploadDict)
        let uploadTask = session.uploadTask(with: uploadURLRequest, from: jsonData) { (receivedData, response, error) in
            print(self.getJSONFrom(data: data) ?? "")
        }
        uploadTask.resume()
    }
    
    @IBAction func clickedOnUploadDelegate(_ sender: Any) {
//        print(#function)
        
        let url = URL(string: "https://httpbin.org/post")!
        var uploadURLRequest = URLRequest(url: url)
        uploadURLRequest.httpMethod = "POST"
        let configuration = URLSessionConfiguration.default
        let session = URLSession(configuration: configuration)
        
        let uploadDict: [String: String] = [
            "Mercedes": "Lewis Hamilton",
            "Ferrari": "Sebastian Vettel",
            "RedBull": "Daniel Ricciardo"
        ]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: uploadDict)
        uploadURLRequest.httpBody = jsonData
        let uploadData = try? JSONEncoder().encode(uploadDict)
        
        guard let data = uploadData
            else {
                print("Unable to create upload data")
                return
        }
        let task = session.dataTask(with: uploadURLRequest)
        task.resume()
        
//        let uploadTask = session.uploadTask(with: uploadURLRequest, from: data)
//        uploadTask.resume()
    }
}

extension ExamplesVC: URLSessionDelegate {
    
    public func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
        print(#function)
    }
    
    public func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        print(#function)
    }
    
    public func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        print(#function)
    }
    
}
