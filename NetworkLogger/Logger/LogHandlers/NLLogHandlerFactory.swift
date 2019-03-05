//
//  NLLogHandlerFactory.swift
//  NetworkLogger
//
//  Created by Sunil Sharma on 26/01/19.
//

import Foundation

public class NLLogHandlerFactory: NSObject {
    
    public func create(_ handlerType: NLLogHandlerType) -> NLLogHandler {
        
        switch handlerType {
        case .console:
            return NLConsoleLogHandler()
        case .slack(let webhookUrl):
            return NLSlackLogHandler(webhookUrl: webhookUrl)
        case .file:
            return NLFileLogHandler(fileName: "NetworkLogFile")
        default:
            return NLConsoleLogHandler()
        }
    }
    
}
