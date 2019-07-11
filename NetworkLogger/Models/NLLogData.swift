//
//  NLLogData.swift
//  NetworkLogger
//
//  Created by Sunil Sharma on 09/07/19.
//  Copyright © 2019 Sunil Sharma. All rights reserved.
//

import Foundation

public enum NLSessionState: Int {
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

public class NLLogData: NSObject {
    
    private(set) var identifier: String?
    internal(set) var urlRequest: URLRequest?
    internal(set) var response: URLResponse?
    internal(set) var receivedData: Data?
    internal(set) var error: Error?
    internal(set) var startTime: Date?
    internal(set) var endTime: Data?
    internal(set) var redirectUrl: String?
    private(set) var state: NLSessionState?
    
    init(identifier: String) {
        self.identifier = identifier
    }
    
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
