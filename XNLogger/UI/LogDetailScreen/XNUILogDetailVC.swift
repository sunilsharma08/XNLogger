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

class XNUILogDetailVC: XNUIBaseViewController {
    
    class func instance() -> XNUILogDetailVC? {
        
        let controller = XNUILogDetailVC(nibName: String(describing: self), bundle: Bundle.current())
        return controller
    }

    @IBOutlet weak var requestBtn: UIButton!
    @IBOutlet weak var responseBtn: UIButton!
    @IBOutlet weak var contentView: UIView!
    
    var logData: XNLogData?
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
        if let logData = self.logData {
            self.logDataConverter = NLUILogDataConverter(logData: logData, formatter: XNUIManager.shared.uiLogHandler.logFormatter)
        }
        selectDefaultTab()
    }
    
    private func configureViews() {
        self.navigationItem.title = "Log details"
        self.view.layoutIfNeeded()
        if (requestView == nil) {
            requestView = XNUILogDetailView(frame: contentView.bounds)
            requestView?.viewType = .request
            requestView?.autoresizingMask = [.flexibleHeight, .flexibleWidth]
            requestView?.translatesAutoresizingMaskIntoConstraints = true
            if let subView = requestView {
                self.contentView.addSubview(subView)
            }
            requestView?.layoutIfNeeded()
        }
        
        if (responseView == nil) {
            responseView = XNUILogDetailView(frame: contentView.bounds)
            responseView?.viewType = .response
            responseView?.autoresizingMask = [.flexibleHeight, .flexibleWidth]
            responseView?.translatesAutoresizingMaskIntoConstraints = true
            if let subView = responseView {
                self.contentView.addSubview(subView)
            }
            responseView?.layoutIfNeeded()
        }
    }
    
    private func selectDefaultTab() {
        self.responseView?.isHidden = true
        self.requestView?.isHidden = false
        self.requestView?.upadteView(with: logDataConverter?.getRequestLogDetails() ?? [])
        self.responseView?.upadteView(with: logDataConverter?.getResponseLogDetails() ?? [])
        clickedOnRequest(UIButton(type: .custom))
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
        selButton.setTitleColor(.white, for: .normal)
        selButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        unSelButton.backgroundColor = UIColor(white: 0.97, alpha: 1)
        unSelButton.setTitleColor(XNUIAppColor.title , for: .normal)
        unSelButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        
    }
}

class NLUILogDataConverter {
    
    private var logData: XNLogData!
    private var formatter: XNLogFormatter!
    let dateFormatter = DateFormatter()
    var cellWidth: Float = 0
    var msgFont: UIFont = XNUIConstants.messageFont
    
    init(logData: XNLogData, formatter: XNLogFormatter) {
        self.logData = logData
        self.formatter = formatter
        self.dateFormatter.dateFormat = "yyyy-MM-dd H:m:ss.SSSS"
    }
    
    func getRequestLogDetails() -> [XNUILogDetail] {
        
        var requestLogs: [XNUILogDetail] = []
        if formatter.showRequest || formatter.showReqstWithResp {
            let urlInfo: XNUILogDetail = XNUILogDetail(title: "URL")
            urlInfo.addMessage(logData.urlRequest.url?.absoluteString ?? "-", maxWidth: cellWidth)
            requestLogs.append(urlInfo)
            if let port = logData.urlRequest.url?.port {
                requestLogs.append(XNUILogDetail(title: "Port", message: "\(port)", maxWidth: cellWidth))
            }
            requestLogs.append(XNUILogDetail(title: "Method", message: logData.urlRequest.httpMethod ?? "-", maxWidth: cellWidth))
            let headerInfo: XNUILogDetail = XNUILogDetail(title: "Header fields")
            if let headerFields = logData.urlRequest.allHTTPHeaderFields, headerFields.isEmpty == false {
                for (key, value) in headerFields {
                    headerInfo.addMessage("\(key) = \(value)", maxWidth: cellWidth)
                }
            } else {
                headerInfo.addMessage("Header field is empty", maxWidth: cellWidth)
            }
            requestLogs.append(headerInfo)
            
            let httpBodyInfo: XNUILogDetail = XNUILogDetail(title: "Http body")
            
            if let httpBody = logData.urlRequest.httpBodyString(prettyPrint: formatter.prettyPrintJSON), httpBody.isEmpty == false {
                // Log HTTP body either `logUnreadableReqstBody` is true or when content is readable.
                if formatter.logUnreadableReqstBody || XNAppUtils.shared.isContentTypeReadable(logData.reqstContentType) {
                    httpBodyInfo.addMessage("\(httpBody)", maxWidth: cellWidth)
                } else {
                    httpBodyInfo.addMessage("\(logData.reqstContentType.getName())", maxWidth: cellWidth)
                    httpBodyInfo.shouldShowDataInFullScreen = true
                }
            } else {
                httpBodyInfo.addMessage("Http body is empty", maxWidth: cellWidth)
            }
            
            requestLogs.append(httpBodyInfo)
            
            if formatter.showCurlWithReqst {
                requestLogs.append(XNUILogDetail(title: "CURL", message: logData.urlRequest.cURL, maxWidth: cellWidth))
            }
            
            let reqstMetaInfo: [XNRequestMetaInfo] = formatter.showReqstMetaInfo
            
            for metaInfo in reqstMetaInfo {
                
                switch metaInfo {
                case .timeoutInterval:
                    requestLogs.append(XNUILogDetail(title: "Timeout interval", message: "\(logData.urlRequest.timeoutInterval)", maxWidth: cellWidth))
                case .cellularAccess:
                    requestLogs.append(XNUILogDetail(title: "Mobile data access allowed", message: "\(logData.urlRequest.allowsCellularAccess)", maxWidth: cellWidth))
                case .cachePolicy:
                    requestLogs.append(XNUILogDetail(title: "Cache policy", message: "\(logData.urlRequest.getCachePolicyName())", maxWidth: cellWidth))
                case .networkType:
                    requestLogs.append(XNUILogDetail(title: "Network service type", message: "\(logData.urlRequest.getNetworkTypeName())", maxWidth: cellWidth))
                case .httpPipeliningStatus:
                    requestLogs.append(XNUILogDetail(title: "HTTP Pipelining will be used", message: "\(logData.urlRequest.httpShouldUsePipelining)", maxWidth: cellWidth))
                case .cookieStatus:
                    requestLogs.append(XNUILogDetail(title: "Cookies will be handled", message: "\(logData.urlRequest.httpShouldHandleCookies)", maxWidth: cellWidth))
                case .requestStartTime:
                    if let startDate: Date = logData.startTime {
                        requestLogs.append(XNUILogDetail(title: "Start time", message: "\(dateFormatter.string(from: startDate))", maxWidth: cellWidth))
                    }
                }
            }
        }
        
        return requestLogs
    }
    
    func getResponseLogDetails() -> [XNUILogDetail] {
        var responseLogs: [XNUILogDetail] = []
        if formatter.showResponse {
            
            let responseInfo: XNUILogDetail = XNUILogDetail(title: "Response Content")
            if let data = logData.receivedData, data.isEmpty == false {
                let jsonUtil = XNJSONUtils()
                if formatter.logUnreadableRespBody || XNAppUtils.shared.isContentTypeReadable(logData.respContentType) {
                    let str = jsonUtil.getJSONStringORStringFrom(jsonData: data, prettyPrint: formatter.prettyPrintJSON)
                    responseInfo.addMessage(str, maxWidth: cellWidth)
                } else {
                    responseInfo.addMessage(logData.respContentType.getName(), maxWidth: cellWidth)
                    responseInfo.shouldShowDataInFullScreen = true
                }
            }
            else {
                responseInfo.addMessage("Respose data is empty", maxWidth: cellWidth)
            }
            responseLogs.append(responseInfo)
            
            let respMetaInfo: XNUILogDetail = XNUILogDetail(title: "Response Meta Info")
            if formatter.showRespMetaInfo.isEmpty == false {
                let respHeaderInfo: XNUILogDetail = XNUILogDetail(title: "Response headers fields:")
                let response = logData.response
                for property in formatter.showRespMetaInfo {
                    
                    switch property {
                    case .statusCode:
                        if let httpResponse = response as? HTTPURLResponse {
                            respMetaInfo.addMessage("Status Code: \(httpResponse.statusCode)", maxWidth: cellWidth)
                        }
                    case .statusDescription:
                        if let httpResponse = response as? HTTPURLResponse {
                            respMetaInfo.addMessage("Status Code description: \(HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode))", maxWidth: cellWidth)
                        }
                    case .mimeType:
                        respMetaInfo.addMessage("Mime type: \(response?.mimeType ?? "-")", maxWidth: cellWidth)
                    case .textEncoding:
                        respMetaInfo.addMessage("Text encoding name: \(response?.textEncodingName ?? "-")", maxWidth: cellWidth)
                    case .contentLength:
                        if let expectedContentLength = response?.expectedContentLength {
                            respMetaInfo.addMessage("Expected content length: \(expectedContentLength)", maxWidth: cellWidth)
                        } else {
                            respMetaInfo.addMessage("Expected content length: -", maxWidth: cellWidth)
                        }
                    case .suggestedFileName:
                        respMetaInfo.addMessage("Suggested file name: \(response?.suggestedFilename ?? "-")", maxWidth: cellWidth)
                    case .headers:
                        if let httpResponse = response as? HTTPURLResponse,
                            httpResponse.allHeaderFields.isEmpty == false {
                            
                            for (key, value) in httpResponse.allHeaderFields {
                                respHeaderInfo.addMessage("\(key) = \(value)", maxWidth: cellWidth)
                            }
                        }
                    case .requestStartTime:
                        if let startDate: Date = logData.startTime {
                            respMetaInfo.addMessage("Start time: \(dateFormatter.string(from: startDate))", maxWidth: cellWidth)
                        }
                    case .duration:
                        if let durationStr: String = logData.getDurationString() {
                            respMetaInfo.addMessage("Duration: " + durationStr, maxWidth: cellWidth)
                        } else {
                            respMetaInfo.addMessage("Duration: -", maxWidth: cellWidth)
                        }
                    }
                }
                responseLogs.append(respMetaInfo)
                if respHeaderInfo.messages.isEmpty == false {
                    responseLogs.append(respHeaderInfo)
                }
            }
            else {
                respMetaInfo.addMessage("Response meta info is empty", maxWidth: cellWidth)
            }
            
            if let error = logData.error {
                responseLogs.append(XNUILogDetail(title: "Response Error", message: error.localizedDescription, maxWidth: cellWidth))
            }
        }
        return responseLogs
    }
}
