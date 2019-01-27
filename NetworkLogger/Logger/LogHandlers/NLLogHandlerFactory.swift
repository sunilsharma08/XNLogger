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
        case .console(let filters):
            return NLConsoleLogHandler(filters: filters)
        case .slack(let webhookUrl):
            return NLSlackLogHandler(webhookUrl: webhookUrl)
        default:
            return NLConsoleLogHandler(filters: nil)
        }
    }
    
}
