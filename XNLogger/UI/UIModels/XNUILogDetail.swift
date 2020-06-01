//
//  NLUILogDetail.swift
//  XNLogger
//
//  Created by Sunil Sharma on 29/08/19.
//  Copyright © 2019 Sunil Sharma. All rights reserved.
//

import Foundation

class XNUILogInfo {
    var identifier: String
    var title: String?
    var state: XNSessionState?
    var statusCode: Int?
    var httpMethod: String?
    var durationStr: String?
    var startTime: Date?
    
    init(logId: String) {
        self.identifier = logId
    }
}

class XNUIMessageData {
    
    var message: String
    var isEmptyDataMsg: Bool = false
    var msgCount: Int = 0
    var msgSize: Int = 0
    var showOnlyInFullScreen: Bool = false
    var data: Data?
    
    init(msg: String) {
        self.message = msg
    }
}

class XNUILogDetail {
    
    var title: String
    var messages: [XNUIMessageData] = []
    
    init(title: String) {
        self.title = title
    }
    
    convenience init(title: String, message: String) {
        self.init(title: title)
        addMessage(message)
    }
    
    func addMessage(_ msg: String, isEmptyDataMsg: Bool = false) {
        let msgInfo = XNUIMessageData(msg: msg)
        msgInfo.msgCount = msg.count
        msgInfo.msgSize = msg.lengthOfBytes(using: .utf8)
        if msgInfo.msgSize > XNUIConstants.msgCellMaxAllowedSize {
            // Data size is too large, not a good idea to displayed in cell.
            msgInfo.showOnlyInFullScreen = true
        }
        msgInfo.isEmptyDataMsg = isEmptyDataMsg
        messages.append(msgInfo)
    }
    
    func addData(_ data: Data) {
        let msgInfo = XNUIMessageData(msg: "")
        msgInfo.data = data
        msgInfo.msgCount = data.count
        msgInfo.msgSize = msgInfo.msgCount
        msgInfo.showOnlyInFullScreen = true
        messages.append(msgInfo)
    }
}
