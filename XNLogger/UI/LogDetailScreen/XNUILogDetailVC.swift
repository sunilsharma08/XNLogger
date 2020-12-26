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
    private var logDataConverter: XNUILogDataConverter?
    private var moreOptionBtn: UIButton?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        edgesForExtendedLayout = []
        automaticallyAdjustsScrollViewInsets = false
        NotificationCenter.default.addObserver(self, selector: #selector(didReceiveUpdate(_:)), name: .logDataUpdate, object: nil)
        
        configureViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(updateViewSource(_:)), name: UIMenuController.willShowMenuNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: UIMenuController.willShowMenuNotification, object: nil)
    }
    
    private func configureViews() {
        self.headerView?.setTitle("Log details")
        self.headerView?.addBackButton(target: self.navigationController, selector: #selector(self.navigationController?.popViewController(animated:)))
        let moreOptionBtn = helper.createNavButton(imageName: "menu", imageInsets: UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 6))
        moreOptionBtn.addTarget(self, action: #selector(clickedOnMoreOptions), for: .touchUpInside)
        self.moreOptionBtn = moreOptionBtn
        
        self.headerView?.addRightBarItems([moreOptionBtn])
        
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

        loadData {[weak self] in
            DispatchQueue.main.safeAsync {
                self?.selectDefaultTab()
                self?.updateUI()
            }
        }
    }
    
    @objc func updateViewSource(_ notification: Notification) {
        // Just to update UITextEffectsWindow level and UIMenuController is visible
        UIApplication.shared.windows.forEach { (windoww) in
            if windoww.className == "UITextEffectsWindow" {
                windoww.windowLevel = .init(CGFloat.greatestFiniteMagnitude)
            }
        }
    }
    
    private func selectDefaultTab() {
        self.responseView?.isHidden = false
        self.requestView?.isHidden = true
        if let requestBtn = self.requestBtn {
            clickedOnRequest(requestBtn)
        }
    }
    
    @objc func didReceiveUpdate(_ notification: Notification) {
        guard let userInfo = notification.userInfo as? [String: Any],
            let logId = userInfo[XNUIConstants.logIdKey] as? String,
            /*Avoid UI update from other request notifications*/
            logId == logInfo?.identifier
            else { return }
        loadData {[weak self] in
            DispatchQueue.main.safeAsync {
                self?.updateUI()
            }
        }
    }
    
    func updateUI() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            self.logDataConverter?.getRequestLogDetails(completion: { (reqLogs) in
                DispatchQueue.main.safeAsync {
                    self.requestView?.upadteView(with: reqLogs)
                }
            })
            
            self.logDataConverter?.getResponseLogDetails(completion: { (respLogs) in
                DispatchQueue.main.safeAsync {
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
                    self.logDataConverter = XNUILogDataConverter(logData: logDataObj, formatter: XNUIManager.shared.uiLogHandler.logFormatter)
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
        
        guard let moreOptionButton = self.moreOptionBtn else { return }
        let popoverVC = XNUIPopOverViewController()
        let optionItems: [XNUIOptionItem] = [
            XNUIOptionItem(title: "Share Request and Response", type: .shareReqtAndResp),
            XNUIOptionItem(title: "Share Request", type: .shareRequest),
            XNUIOptionItem(title: "Share Response", type: .shareResponse)
        ]
        popoverVC.items = optionItems
        popoverVC.delegate = self
        var sourceRect = moreOptionButton.convert(moreOptionButton.frame, to: self.headerView)
        if let headerView = self.headerView {
            sourceRect = headerView.convert(sourceRect, to: self.view)
        }
        popoverVC.popoverPresentationController?.sourceRect = sourceRect
        popoverVC.popoverPresentationController?.sourceView = self.view

        self.present(popoverVC, animated: true, completion: nil)
    }
    
    func showShareController(shareOption: XNUIShareOption) {
        
        func showError(message: String = "Unable to perform action.") {
            XNUIHelper().showError(on: self, message: message)
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
        
        helper.showActivityIndicator(on: self.view)
        shareDetails.preProcess {[weak self] (completed) in
            guard let self = self else {
                shareDetails.clean()
                return
            }
            
            DispatchQueue.main.safeAsync {
                self.helper.hideActivityIndicator(from: self.view)
                
                let saveToDesktopActivities = [XNUISaveToDesktopActivity(), XNUISaveToPathActivity()]
                
                let shareVC = UIActivityViewController(activityItems: [shareDetails], applicationActivities: saveToDesktopActivities)
                if (UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad) {
                    
                    guard let moreOptionButton = self.moreOptionBtn else { return }
                    var sourceRect = moreOptionButton.convert(moreOptionButton.frame, to: self.headerView)
                    if let headerView = self.headerView {
                        sourceRect = headerView.convert(sourceRect, to: self.view)
                    }
                    
                    shareVC.popoverPresentationController?.sourceView = self.view
                    shareVC.popoverPresentationController?.sourceRect = sourceRect
                }
                shareVC.completionWithItemsHandler = {(activityType, completed, returnedItems, activityError) in
                    
                    shareDetails.clean()
                    if let error = activityError {
                        XNUIHelper().showError(on: self, message: error.localizedDescription)
                    }
                }
                self.present(shareVC, animated: true)
            }
        }
    }
    
    deinit {
        // print("\(type(of: self)) \(#function)")
        NotificationCenter.default.removeObserver(self, name: .logDataUpdate, object: nil)
    }
}

extension XNUILogDetailVC: XNUIDetailViewDelegate {
    
    func showMessageFullScreen(logData: XNUIMessageData, title: String) {
        if let controller = XNUIResponseFullScreenVC.controller(title: title, logData: logData) {
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
}

extension XNUILogDetailVC: XNUIPopoverDelegate {
    
    func popover(_ popover: XNUIPopOverViewController, didSelectItem item: XNUIOptionItem, indexPath: IndexPath) {
        
        popover.dismiss(animated: false) {[weak self] in
            guard let self = self else { return }
            
            switch item.type {
            case .shareReqtAndResp:
                self.showShareController(shareOption: .reqtAndResp)
            case .shareRequest:
                self.showShareController(shareOption: .request)
            case .shareResponse:
                self.showShareController(shareOption: .response)
            default:
                break
            }
        }
    }
}

class XNUILogDataConverter {
    
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
