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
        case .slack(let slackUserInfo):
            return NLSlackLogHandler(slackUserInfo: slackUserInfo)
        default:
            return NLConsoleLogHandler(filters: nil)
        }
    }
    
}
