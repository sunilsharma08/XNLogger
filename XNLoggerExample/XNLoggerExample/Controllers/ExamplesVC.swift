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
    
    @IBAction func clickedOnShowXNLogger() {
        XNUIManager.shared.presentNetworkLogUI()
    }
}

// Data task
extension ExamplesVC {
    
    @IBAction func clickedOnDataHandler(_ sender: Any) {
        
        let url = URL(string: "https://gorest.co.in/public-api/users?_format=json&access-token=Vy0X23HhPDdgNDNxVocmqv3NIkDTGdK93GfV")!
        
        var urlRequest: URLRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.addValue("alloo", forHTTPHeaderField: "sabji")
        urlRequest.setValue("gjghj", forHTTPHeaderField: "llnlnoln")
        let json: [String: Any] = ["title": "AB'C",
                                   "dict": ["1":"First", "2":"Second"]]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        urlRequest.httpBody = jsonData
        let session = URLSession.shared
        
        session.dataTask(with: urlRequest) { (data, urlResponse, error) in
            print(self.getJSONFrom(data: data) ?? "")
        }.resume()
    }
    
    @IBAction func clickedOnDataDelegate(_ sender: Any) {
        
        let url = URL(string: "https://httpbin.org/get")!
        let configuration = URLSessionConfiguration.ephemeral
        let session = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
        
        let task = session.dataTask(with: URLRequest(url: url))
        task.resume()
    }
    
}

// Download task
extension ExamplesVC {
    
    @IBAction func clickedOnDownloadHandler(_ sender: Any) {
        
        let url = URL(string: "https://source.unsplash.com/collection/400620/250x350")!
        let configuration = URLSessionConfiguration.default
        let session = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
        let task = session.downloadTask(with: url) { (fileUrl, response, error) in
            print("Downloaded file url \(fileUrl?.absoluteString ?? "nil")")
        }
        task.resume()
    }
    
    @IBAction func clickedOnDownloadDelegate(_ sender: Any) {
        
        let url = URL(string: "https://source.unsplash.com/collection/400620/250x350")!
        let configuration = URLSessionConfiguration.default
        let session = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
        let task = session.downloadTask(with: url)
        task.resume()
    }
    
    @IBAction func clickedOnResumeDownload(_ sender: Any) {
        
        guard let button = sender as? UIButton
            else { return }
        /**
         Video Urls
         https://file-examples.com/wp-content/uploads/2018/04/file_example_AVI_480_750kB.avi
         http://file-examples.com/wp-content/uploads/2017/04/file_example_MP4_640_3MG.mp4
         https://file-examples.com/wp-content/uploads/2018/04/file_example_OGG_480_1_7mg.ogg
         https://file-examples.com/wp-content/uploads/2018/04/file_example_MOV_480_700kB.mov
         https://docs.google.com/uc?export=download&id=1NmdZuEQmxyYgptuPJtacoFC3d8Yj8bQY
         http://techslides.com/demos/sample-videos/small.3gp
         
         PDF
         https://file-examples.com/wp-content/uploads/2017/10/file-sample_150kB.pdf
         Images
         https://file-examples.com/wp-content/uploads/2017/10/file_example_JPG_100kB.jpg
         https://file-examples.com/wp-content/uploads/2017/10/file_example_PNG_500kB.png
         https://file-examples.com/wp-content/uploads/2017/10/file_example_GIF_500kB.gif
         https://file-examples.com/wp-content/uploads/2017/10/file_example_TIFF_1MB.tiff
         https://file-examples.com/wp-content/uploads/2017/10/file_example_favicon.ico
         https://file-examples.com/wp-content/uploads/2020/03/file_example_SVG_20kB.svg
         https://file-examples.com/wp-content/uploads/2020/03/file_example_WEBP_50kB.webp
         
         Audio
         https://file-examples.com/wp-content/uploads/2017/11/file_example_MP3_700KB.mp3
         
         Text
         https://file-examples.com/wp-content/uploads/2017/02/file_example_CSV_5000.csv
         https://file-examples.com/wp-content/uploads/2017/02/file_example_JSON_1kb.json
         https://file-examples.com/wp-content/uploads/2017/02/file_example_XML_24kb.xml
         https://file-examples.com/wp-content/uploads/2017/02/index.html
         https://file-examples.com/wp-content/uploads/2019/09/file-sample_100kB.rtf
         */
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
        
        let url = URL(string: "http://doanarae.com/doanarae/8880-5k-desktop-wallpaper_23842.jpg")!
        let configuration = URLSessionConfiguration.background(withIdentifier: "com.\(UUID().uuidString)")
        let session = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
        let task = session.downloadTask(with: url)
        task.resume()
        
    }
    
    @IBAction func clickedOnWebView(_ sender: Any) {
        /*
        guard let button = sender as? UIButton else { return }
        webView.removeFromSuperview()
        webView = WKWebView(frame: CGRect(x: 20, y: button.frame.maxY + 10, width: self.view.frame.width - 40, height: 300))
        webView.backgroundColor = UIColor.orange
        self.view.addSubview(webView)
//        webView.loadRequest(URLRequest(url: URL(string: "https://source.unsplash.com/collection/400620/250x350")!))
        webView.load(URLRequest(url: URL(string: "https://source.unsplash.com/collection/400620/250x350")!))
        */
    }
    
}

// Upload task
extension ExamplesVC {
    
    @IBAction func clickedOnUploadHandler(_ sender: Any) {
        
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
        
        let task = session.dataTask(with: uploadURLRequest)
        task.resume()
    }
}

extension ExamplesVC: URLSessionDelegate {
    
    public func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
        print(#function)
    }
    
    public func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        print(#function)
        completionHandler(.performDefaultHandling, nil)
    }
    
    public func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        print(#function)
    }
}
