//
//  NLLogData.swift
//  NetworkLogger
//
//  Created by Sunil Sharma on 09/07/19.
//  Copyright © 2019 Sunil Sharma. All rights reserved.
//

import Foundation

enum NLSessionState: Int {
    case running
    case suspended
    case canceling
    case completed
    case unknown
    
    func getName() -> String {
        switch self {
        case .running:
            return "Running..."
        case .suspended:
            return "Suspended"
        case .canceling:
            return "Canceling"
        case .completed:
            return "Completed"
        case .unknown:
            return "Unknown"
        }
    }
}

class NLLogData {
    
    var urlRequest: URLRequest?
    var responseData: NLResponseData?
    var startTime: Date?
    var endTime: Data?
    var redirectUrl: String?
    private(set) var state: NLSessionState?
    
    func setSessionState(_ state: URLSessionTask.State?) {
        guard let state = state else {
            self.state = .unknown
            return
        }
        switch state {
        case .running:
            self.state = .running
        case .suspended:
            self.state = .suspended
        case .canceling:
            self.state = .canceling
        case .completed:
            self.state = .completed
        }
    }
}
