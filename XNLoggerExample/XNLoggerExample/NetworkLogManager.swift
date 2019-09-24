//
//  NetworkLogManager.swift
//  NetworkLogger
//
//  Created by Sunil Sharma on 16/12/18.
//  Copyright © 2018 Sunil Sharma. All rights reserved.
//

import Foundation
import XNLogger

@objc class NetworkLogManager: NSObject {
    
    @objc public static let shared = NetworkLogManager()
    
    override private init() {}
    
    @objc func logNetworkRequests() {
//        let filterFactory = NLFilterFactory()
//        let containFilter = filterFactory.exclude(.contains("vvalues"))
//        let anotherFilter = filterFactory.filter(.contains("publics"))
//        let logHandlerFactory = NLLogHandlerFactory()
//        NetworkLogger.shared.addLogHandler(logHandlerFactory.create(.slack("<slackwebhookurl>")))
        let consoleHandler = XNConsoleLogHandler.create()
//
//        consoleHandler.addFilters([anotherFilter])
        XNLogger.shared.addLogHandlers([consoleHandler])
//        NetworkLogger.shared.stopLogging()
//        let formatter = NLLogFormatter()
//        formatter.showRequestProperties = NLRequestProperty.allCases
//        for value in formatter.showRequestProperties {
//            print(value.rawValue)
//        }
//        print("Logging network tasks")
//
    }
    
}
