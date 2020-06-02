//
//  XNUIResponseFullScreenVC.swift
//  XNLogger
//
//  Created by Sunil Sharma on 04/04/20.
//  Copyright © 2020 Sunil Sharma. All rights reserved.
//

import Foundation
import WebKit

class XNUIResponseFullScreenVC: XNUIBaseViewController {
    
    @IBOutlet weak var mediaWebView: WKWebView!
    @IBOutlet weak var msgTextView: XNUILogTextView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var headerTitle: String!
    var logData: XNUIMessageData!
    let fileService: XNUIFileService = XNUIFileService()
    var isFirstLoad: Bool = true
    
    class func controller(title: String, logData: XNUIMessageData) -> XNUIResponseFullScreenVC? {
        let controller = XNUIResponseFullScreenVC(nibName: String(describing: self), bundle: Bundle.current())
        controller.logData = logData
        controller.headerTitle = title
        return controller
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if isFirstLoad {
            isFirstLoad = false
            loadData()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if self.navigationController?.viewControllers.index(of: self) == nil {
            if let fileURL = self.mediaWebView.url {
                fileService.removeFile(url: fileURL)
            }
        }
    }
    
    func configureViews() {
        self.navigationItem.title = headerTitle
        self.activityIndicator.hidesWhenStopped = true
        self.msgTextView.text = nil
        self.mediaWebView.navigationDelegate = self
        self.mediaWebView.customUserAgent = "XNLoggerExamples/5.0 (iPhone; CPU iPhone OS 11_2 like Mac OS X) AppleWebKit/604.4.7 (KHTML, like Gecko) ExampleApp/1.0 (iPhone)"
    }
    
    func loadData() {
        self.view.layoutIfNeeded()
        self.showActivityIndicator()
        // Check for readable text
        if logData.message.isEmpty == false {
            self.mediaWebView.isHidden = true
            self.msgTextView.isHidden = false
            self.msgTextView.text = logData.message
            self.hideActivityIndicator()
        } else if let contentData = self.logData.data, let ext = self.logData.fileMeta?.ext {
            self.mediaWebView.isHidden = false
            self.msgTextView.isHidden = true
            
            fileService.writeMedia(data: contentData, ext: ext) {[weak self] (fileUrl) in
                guard let self = self else { return }
                
                DispatchQueue.main.async {
                    if let fileURL = fileUrl {
                        self.mediaWebView.loadFileURL(fileURL, allowingReadAccessTo: fileURL.deletingLastPathComponent())
                    } else {
                        self.hideActivityIndicator()
                        self.showError(message: "Something went wrong while processing file.")
                    }
                }
            }
        }
        else {
            self.hideActivityIndicator()
            self.showError(message: "Something went wrong while processing file.")
        }
    }
    
    func showError(title: String = "Error", message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "Ok", style: .default) { (action) in
            alertController.dismiss(animated: true, completion: nil)
        }
        
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func showActivityIndicator() {
        self.view.bringSubviewToFront(activityIndicator)
        self.activityIndicator.startAnimating()
    }
    
    func hideActivityIndicator() {
        self.view.sendSubviewToBack(activityIndicator)
        self.activityIndicator.stopAnimating()
    }
}

extension XNUIResponseFullScreenVC: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.hideActivityIndicator()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        self.hideActivityIndicator()
    }
}
