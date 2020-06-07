//
//  XNUILogDetailVC.swift
//  XNLogger
//
//  Created by Sunil Sharma on 27/08/19.
//  Copyright © 2019 Sunil Sharma. All rights reserved.
//

import UIKit

enum XNUIDetailViewType {
    case request
    case response
}

enum XNUIShareOption {
    case request
    case response
    case reqtAndResp
}

class XNUILogDetailVC: XNUIBaseViewController {
    
    class func instance() -> XNUILogDetailVC? {
        
        let controller = XNUILogDetailVC(nibName: String(describing: self), bundle: Bundle.current())
        return controller
    }

    @IBOutlet weak var requestBtn: UIButton!
    @IBOutlet weak var responseBtn: UIButton!
    @IBOutlet weak var contentView: UIView!
    
    var logInfo: XNUILogInfo?
    private var requestView: XNUILogDetailView?
    private var responseView: XNUILogDetailView?
    private var isResponseSelected: Bool = false
    private var logDataConverter: NLUILogDataConverter?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        edgesForExtendedLayout = []
        automaticallyAdjustsScrollViewInsets = false
        tabBarController?.tabBar.isHidden = true
        
        configureViews()
    }
    
    private func configureViews() {
        self.navigationItem.title = "Log details"
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(clickedOnMoreOptions))
        
        self.view.layoutIfNeeded()
        
        if (requestView == nil) {
            requestView = XNUILogDetailView(frame: contentView.bounds)
            requestView?.viewType = .request
            requestView?.delegate = self
            requestView?.autoresizingMask = [.flexibleHeight, .flexibleWidth]
            requestView?.translatesAutoresizingMaskIntoConstraints = true
            if let subView = requestView {
                self.contentView.addSubview(subView)
            }
        }
        
        if (responseView == nil) {
            responseView = XNUILogDetailView(frame: contentView.bounds)
            responseView?.viewType = .response
            responseView?.delegate = self
            responseView?.autoresizingMask = [.flexibleHeight, .flexibleWidth]
            responseView?.translatesAutoresizingMaskIntoConstraints = true
            if let subView = responseView {
                self.contentView.addSubview(subView)
            }
        }
        
        loadData {
            DispatchQueue.main.async { self.selectDefaultTab() }
        }
    }
    
    private func selectDefaultTab() {
        self.responseView?.isHidden = false
        self.requestView?.isHidden = true
        if let requestBtn = self.requestBtn {
            clickedOnRequest(requestBtn)
        }
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            self.logDataConverter?.getRequestLogDetails(completion: { (reqLogs) in
                DispatchQueue.main.async {
                    self.requestView?.upadteView(with: reqLogs)
                }
            })
            
            self.logDataConverter?.getResponseLogDetails(completion: { (respLogs) in
                DispatchQueue.main.async {
                    self.responseView?.upadteView(with: respLogs)
                }
            })
        }
    }
    
    func loadData(completion: @escaping () -> Void) {
        
        if let logId = self.logInfo?.identifier {
            let fileService: XNUIFileService = XNUIFileService()
            
            fileService.getLogData(for: logId) {[weak self] (logData) in
                guard let self = self else { return }
                
                if let logDataObj = logData {
                    self.logDataConverter = NLUILogDataConverter(logData: logDataObj, formatter: XNUIManager.shared.uiLogHandler.logFormatter)
                }
                completion()
            }
        }
    }
    
    @IBAction func clickedOnRequest(_ sender: Any) {
        self.isResponseSelected = false
        updateReqRespBtn(isRespSelected: isResponseSelected)
    }
    
    @IBAction func clickedOnResponse(_ sender: Any) {
        self.isResponseSelected = true
        updateReqRespBtn(isRespSelected: isResponseSelected)
    }
    
    func updateReqRespBtn(isRespSelected: Bool) {
        
        let selButton: UIButton
        let unSelButton: UIButton
        
        if isRespSelected {
            selButton = responseBtn
            unSelButton = requestBtn
            self.requestView?.isHidden = true
            self.responseView?.isHidden = false
        } else {
            selButton = requestBtn
            unSelButton = responseBtn
            self.responseView?.isHidden = true
            self.requestView?.isHidden = false
        }
        
        selButton.backgroundColor = XNUIAppColor.lightPrimary
        selButton.layer.borderColor = nil
        selButton.layer.borderWidth = 0
        selButton.setTitleColor(.white, for: .normal)
        selButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        unSelButton.backgroundColor = UIColor(white: 0.99, alpha: 1)
        unSelButton.setTitleColor(XNUIAppColor.title , for: .normal)
        unSelButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        unSelButton.layer.borderColor = UIColor(white: 0.9, alpha: 1).cgColor
        unSelButton.layer.borderWidth = 1
        
    }
    
    @objc func clickedOnMoreOptions() {
        
        let actionSheet = UIAlertController(title: "Actions", message: nil, preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Share Request and Response", style: .default , handler:{ (alertAction) in
            self.showShareController(shareOption: .reqtAndResp)
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Share Response", style: .default , handler: { (alertAction) in
            self.showShareController(shareOption: .response)
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Share Request", style: .default , handler: { (alertAction) in
            self.showShareController(shareOption: .request)
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel , handler: { (alertAction) in
            actionSheet.dismiss(animated: true, completion: nil)
        }))
        
        present(actionSheet, animated: true, completion: nil)
    }
    
    func showShareController(shareOption: XNUIShareOption) {
        
        func showError(message: String = "Unable to perform action.") {
            XNUIHelper().showError(on: self, message: "Unable to perform action.")
        }
        
        var shareList: [XNUILogDetail] = []
        switch shareOption {
        case .request:
            if let reqList = requestView?.detailsArray {
                shareList.append(contentsOf: reqList)
            } else {
                showError()
            }
        case .response:
            if let respList = responseView?.detailsArray {
                shareList.append(contentsOf: respList)
            } else {
                showError()
            }
        case .reqtAndResp:
            if let reqList = requestView?.detailsArray, let respList = responseView?.detailsArray {
                shareList.append(contentsOf: reqList)
                shareList.append(contentsOf: respList)
            } else {
                showError()
            }
        }
        let shareDetails = XNUIShareData(logDetails: shareList)
        let ac = UIActivityViewController(activityItems: [shareDetails], applicationActivities: nil)
        ac.completionWithItemsHandler = {(activityType, completed, returnedItems, activityError) in
            shareDetails.clean()
            if let error = activityError {
                showError(message: error.localizedDescription)
            }
        }
        present(ac, animated: true)
    }
}

extension XNUILogDetailVC: XNUIDetailViewDelegate {
    
    func showMessageFullScreen(logData: XNUIMessageData, title: String) {
        if let controller = XNUIResponseFullScreenVC.controller(title: title, logData: logData) {
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
}

class NLUILogDataConverter {
    
    private var logData: XNLogData!
    private var formatter: XNLogFormatter!
    let dateFormatter = DateFormatter()
    var msgFont: UIFont = XNUIConstants.messageFont
    
    init(logData: XNLogData, formatter: XNLogFormatter) {
        self.logData = logData
        self.formatter = formatter
        self.dateFormatter.dateFormat = "yyyy-MM-dd H:m:ss.SSSS"
    }
    
    func getRequestLogDetails(completion: @escaping (_ reqLogDetails: [XNUILogDetail]) -> Void) {
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            var requestLogs: [XNUILogDetail] = []
            if self.formatter.showRequest || self.formatter.showReqstWithResp {
                let urlInfo: XNUILogDetail = XNUILogDetail(title: "URL")
                urlInfo.addMessage(self.logData.urlRequest.url?.absoluteString ?? "-")
                requestLogs.append(urlInfo)
                if let port = self.logData.urlRequest.url?.port {
                    requestLogs.append(XNUILogDetail(title: "Port", message: "\(port)"))
                }
                requestLogs.append(XNUILogDetail(title: "Method", message: self.logData.urlRequest.httpMethod ?? "-"))
                let headerInfo: XNUILogDetail = XNUILogDetail(title: "Header fields")
                if let headerFields = self.logData.urlRequest.allHTTPHeaderFields, headerFields.isEmpty == false {
                    for (key, value) in headerFields {
                        headerInfo.addMessage("\(key) = \(value)")
                    }
                } else {
                    headerInfo.addMessage("Header field is empty", isEmptyDataMsg: true)
                }
                requestLogs.append(headerInfo)
                
                let httpBodyInfo: XNUILogDetail = XNUILogDetail(title: "Http body")
                
                if let httpBody = self.logData.urlRequest.httpBodyString(prettyPrint: self.formatter.prettyPrintJSON), httpBody.isEmpty == false {
                    // Log HTTP body either `logUnreadableReqstBody` is true or when content is readable.
                    if XNAppUtils.shared.isContentTypeReadable(self.logData.reqstContentMeta.contentType) {
                        httpBodyInfo.addMessage("\(httpBody)")
                    } else if self.formatter.logUnreadableReqstBody, let httpBodyData = self.logData.urlRequest.getHttpBodyData() {
                        httpBodyInfo.addData(httpBodyData, fileMeta: self.logData.reqstContentMeta)
                    } else {
                        httpBodyInfo.addMessage(self.logData.reqstContentMeta.contentType.getName() + " data")
                    }
                }
                else {
                    httpBodyInfo.addMessage("Http body is empty", isEmptyDataMsg: true)
                }
                
                requestLogs.append(httpBodyInfo)
                
                if self.formatter.showCurlWithReqst {
                    requestLogs.append(XNUILogDetail(title: "CURL", message: self.logData.urlRequest.cURL))
                }
                
                let reqstMetaInfo: [XNRequestMetaInfo] = self.formatter.showReqstMetaInfo
                
                for metaInfo in reqstMetaInfo {
                    
                    switch metaInfo {
                    case .timeoutInterval:
                        requestLogs.append(XNUILogDetail(title: "Timeout interval", message: "\(self.logData.urlRequest.timeoutInterval)"))
                    case .cellularAccess:
                        requestLogs.append(XNUILogDetail(title: "Mobile data access allowed", message: "\(self.logData.urlRequest.allowsCellularAccess)"))
                    case .cachePolicy:
                        requestLogs.append(XNUILogDetail(title: "Cache policy", message: "\(self.logData.urlRequest.getCachePolicyName())"))
                    case .networkType:
                        requestLogs.append(XNUILogDetail(title: "Network service type", message: "\(self.logData.urlRequest.getNetworkTypeName())"))
                    case .httpPipeliningStatus:
                        requestLogs.append(XNUILogDetail(title: "HTTP Pipelining will be used", message: "\(self.logData.urlRequest.httpShouldUsePipelining)"))
                    case .cookieStatus:
                        requestLogs.append(XNUILogDetail(title: "Cookies will be handled", message: "\(self.logData.urlRequest.httpShouldHandleCookies)"))
                    case .requestStartTime:
                        if let startDate: Date = self.logData.startTime {
                            requestLogs.append(XNUILogDetail(title: "Start time", message: "\(self.dateFormatter.string(from: startDate))"))
                        }
                    }
                }
            }
            completion(requestLogs)
        }
    }
    
    func getResponseLogDetails(completion: @escaping (_ respLogDetails: [XNUILogDetail]) -> Void) {
        
        DispatchQueue.global(qos: .userInitiated).async {[weak self] in
            guard let self = self else { return }
            
            var responseLogs: [XNUILogDetail] = []
            if self.formatter.showResponse {
                
                let responseInfo: XNUILogDetail = XNUILogDetail(title: "Response Content")
                if let data = self.logData.receivedData, data.isEmpty == false {
                    let jsonUtil = XNJSONUtils()
                    if XNAppUtils.shared.isContentTypeReadable(self.logData.respContentMeta.contentType) {
                        let str = jsonUtil.getJSONStringORStringFrom(jsonData: data, prettyPrint: self.formatter.prettyPrintJSON)
                        responseInfo.addMessage(str)
                    } else if self.formatter.logUnreadableRespBody, let responseData = self.logData.receivedData {
                        responseInfo.addData(responseData, fileMeta: self.logData.respContentMeta, suggestedFileName: self.logData.response?.suggestedFilename)
                    } else {
                        responseInfo.addMessage(self.logData.respContentMeta.contentType.getName() + " data")
                    }
                }
                else {
                    responseInfo.addMessage("Respose data is empty", isEmptyDataMsg: true)
                }
                responseLogs.append(responseInfo)
                
                let respMetaInfo: XNUILogDetail = XNUILogDetail(title: "Response Meta Info")
                if self.formatter.showRespMetaInfo.isEmpty == false {
                    let respHeaderInfo: XNUILogDetail = XNUILogDetail(title: "Response headers fields")
                    let response = self.logData.response
                    for property in self.formatter.showRespMetaInfo {
                        
                        switch property {
                        case .statusCode:
                            if let httpResponse = response as? HTTPURLResponse {
                                respMetaInfo.addMessage("Status Code: \(httpResponse.statusCode)")
                            }
                        case .statusDescription:
                            if let httpResponse = response as? HTTPURLResponse {
                                respMetaInfo.addMessage("Status Code description: \(HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode))")
                            }
                        case .mimeType:
                            respMetaInfo.addMessage("Mime type: \(response?.mimeType ?? "-")")
                        case .textEncoding:
                            respMetaInfo.addMessage("Text encoding name: \(response?.textEncodingName ?? "-")")
                        case .contentLength:
                            if let expectedContentLength = response?.expectedContentLength {
                                respMetaInfo.addMessage("Expected content length: \(expectedContentLength)")
                            } else {
                                respMetaInfo.addMessage("Expected content length: -")
                            }
                        case .suggestedFileName:
                            respMetaInfo.addMessage("Suggested file name: \(response?.suggestedFilename ?? "-")")
                        case .headers:
                            if let httpResponse = response as? HTTPURLResponse,
                                httpResponse.allHeaderFields.isEmpty == false {
                                
                                for (key, value) in httpResponse.allHeaderFields {
                                    respHeaderInfo.addMessage("\(key) = \(value)")
                                }
                            }
                        case .requestStartTime:
                            if let startDate: Date = self.logData.startTime {
                                respMetaInfo.addMessage("Start time: \(self.dateFormatter.string(from: startDate))")
                            }
                        case .duration:
                            if let durationStr: String = self.logData.getDurationString() {
                                respMetaInfo.addMessage("Duration: " + durationStr)
                            } else {
                                respMetaInfo.addMessage("Duration: -")
                            }
                        }
                    }
                    responseLogs.append(respMetaInfo)
                    if respHeaderInfo.messages.isEmpty == false {
                        responseLogs.append(respHeaderInfo)
                    }
                }
                else {
                    respMetaInfo.addMessage("Response meta info is empty", isEmptyDataMsg: true)
                }
                
                if let error = self.logData.error {
                    responseLogs.append(XNUILogDetail(title: "Response Error", message: error.localizedDescription))
                }
            }
            completion(responseLogs)
        }
    }
}
