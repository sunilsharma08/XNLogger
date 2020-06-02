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
    var fileMeta: XNFileMeta?
    
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
    
    func addData(_ data: Data, fileMeta: XNFileMeta, suggestedFileName: String? = nil) {
        let msgInfo = XNUIMessageData(msg: "")
        msgInfo.data = data
        msgInfo.msgCount = data.count
        msgInfo.msgSize = msgInfo.msgCount
        msgInfo.fileMeta = fileMeta
        msgInfo.showOnlyInFullScreen = true
        /**
         If unable to get extension from mimeType/sniff then
         try to get file extension from suggested file name.
         */
        if fileMeta.ext == nil, let fileName = suggestedFileName {
            msgInfo.fileMeta?.ext = fileName.components(separatedBy: ".").last
        }
        messages.append(msgInfo)
    }
}
