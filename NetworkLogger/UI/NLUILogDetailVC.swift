//
//  NLUILogDetailViewController.swift
//  NetworkLogger
//
//  Created by Sunil Sharma on 27/08/19.
//  Copyright © 2019 Sunil Sharma. All rights reserved.
//

import UIKit

class NLUILogDetailVC: NLUIBaseViewController {
    
    class func instance() -> NLUILogDetailVC? {
        
        let controller = NLUILogDetailVC(nibName: String(describing: self), bundle: Bundle.current())
        return controller
    }

    @IBOutlet weak var requestBtn: UIButton!
    @IBOutlet weak var responseBtn: UIButton!
    @IBOutlet weak var contentView: UIView!
    
    var logData: NLLogData?
    private var requestView: NLUILogDetailView?
    private var responseView: NLUILogDetailView?
    private var isResponseSelected: Bool = false
    private var logDataConverter: NLUILogDataConverter?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViews()
        if let logData = self.logData {
            self.logDataConverter = NLUILogDataConverter(logData: logData, formatter: NLUIManager.shared.uiLogHandler.logFormatter)
        }
        selectDefaultTab()
    }
    
    private func configureViews() {
        self.navigationItem.title = "Log details"
        self.view.layoutIfNeeded()
        if (requestView == nil) {
            requestView = NLUILogDetailView.loadNib() as? NLUILogDetailView
            requestView?.frame = contentView.bounds
            if let subView = requestView {
                self.contentView.addSubview(subView)
            }
        }
        
        if (responseView == nil) {
            responseView = NLUILogDetailView.loadNib() as? NLUILogDetailView
            responseView?.frame = contentView.bounds
            if let subView = responseView {
                self.contentView.addSubview(subView)
            }
        }
    }
    
    private func selectDefaultTab() {
        self.responseView?.isHidden = true
        self.requestView?.isHidden = false
        self.requestView?.upadteView(with: logDataConverter?.getRequestLogDetails() ?? [])
    }
    
    @IBAction func clickedOnRequest(_ sender: Any) {
        if isResponseSelected {
            self.responseView?.isHidden = true
        }
        self.requestView?.isHidden = false
        self.isResponseSelected = false
    }
    
    @IBAction func clickedOnResponse(_ sender: Any) {
        if isResponseSelected == false {
            self.requestView?.isHidden = true
        }
        self.responseView?.isHidden = false
        self.isResponseSelected = true
    }

}

class NLUILogDataConverter {
    
    private var logData: NLLogData!
    private var formatter: NLLogFormatter!
    
    init(logData: NLLogData, formatter: NLLogFormatter) {
        self.logData = logData
        self.formatter = formatter
    }
    
    func getRequestLogDetails() -> [NLUILogDetail] {
        var requestLogs: [NLUILogDetail] = []
        if formatter.showRequest {
            let urlInfo: NLUILogDetail = NLUILogDetail(title: "URL")
            urlInfo.messages.append(logData.urlRequest.url?.absoluteString ?? "-")
            requestLogs.append(urlInfo)
            if let port = logData.urlRequest.url?.port {
                requestLogs.append(NLUILogDetail(title: "Port", message: "\(port)"))
            }
            requestLogs.append(NLUILogDetail(title: "Method", message: logData.urlRequest.httpMethod ?? "-"))
            let headerInfo: NLUILogDetail = NLUILogDetail(title: "Headers field")
            if let headerFields = logData.urlRequest.allHTTPHeaderFields, headerFields.isEmpty == false {
                for (key, value) in headerFields {
                    headerInfo.messages.append("\(key) = \(value)")
                }
            } else {
                headerInfo.messages.append("Header field is empty")
            }
            
            let httpBodyInfo: NLUILogDetail = NLUILogDetail(title: "Http body")
            
            if let httpBody = logData.urlRequest.httpBodyString(prettyPrint: formatter.prettyPrintJSON), httpBody.isEmpty == false {
                // Log HTTP body either `logUnreadableReqstBody` is true or when content is readable.
                if formatter.logUnreadableReqstBody || AppUtils.shared.isContentTypeReadable(logData.reqstContentType) {
                    httpBodyInfo.messages.append("\(httpBody)")
                } else {
                    httpBodyInfo.messages.append("\(logData.reqstContentType.getName())")
                    httpBodyInfo.shouldShowDataInFullScreen = true
                }
            } else {
                httpBodyInfo.messages.append("Http body is empty")
            }
            
            requestLogs.append(httpBodyInfo)
            
            if formatter.showCurlWithReqst {
                requestLogs.append(NLUILogDetail(title: "CURL", message: logData.urlRequest.cURL))
            }
            
            let reqstMetaInfo: [NLRequestMetaInfo] = formatter.showReqstMetaInfo
            
            for metaInfo in reqstMetaInfo {
                
                switch metaInfo {
                case .timeoutInterval:
                    requestLogs.append(NLUILogDetail(title: "Timeout interval", message: "\(logData.urlRequest.timeoutInterval)"))
                case .cellularAccess:
                    requestLogs.append(NLUILogDetail(title: "Mobile data access allowed", message: "\(logData.urlRequest.allowsCellularAccess)"))
                case .cachePolicy:
                    requestLogs.append(NLUILogDetail(title: "Cache policy", message: "\(logData.urlRequest.getCachePolicyName())"))
                case .networkType:
                    requestLogs.append(NLUILogDetail(title: "Network service type", message: "\(logData.urlRequest.getNetworkTypeName())"))
                case .httpPipeliningStatus:
                    requestLogs.append(NLUILogDetail(title: "HTTP Pipelining will be used", message: "\(logData.urlRequest.httpShouldUsePipelining)"))
                case .cookieStatus:
                    requestLogs.append(NLUILogDetail(title: "Cookies will be handled", message: "\(logData.urlRequest.httpShouldHandleCookies)"))
                case .requestStartTime:
                    if let startDate: Date = logData.startTime {
                        let dateFormatter = DateFormatter()
                        requestLogs.append(NLUILogDetail(title: "Start time", message: "\(dateFormatter.string(from: startDate))"))
                    }
                }
            }
        }
        
        return requestLogs
    }
}
