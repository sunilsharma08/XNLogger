//
//  NLUILogDetail.swift
//  XNLogger
//
//  Created by Sunil Sharma on 29/08/19.
//  Copyright © 2019 Sunil Sharma. All rights reserved.
//

import Foundation

class XNUIMessageData {
    
    var message: String
    var msgLength: Int = 0
    var msgSize: Int = 0
    
    init(msg: String) {
        self.message = msg
    }
}

class XNUILogDetail {
    
    var title: String
    var messages: [XNUIMessageData] = []
    var isExpended: Bool = false
    var shouldShowDataInFullScreen: Bool = false
    
    init(title: String) {
        self.title = title
    }
    
    convenience init(title: String, message: String) {
        self.init(title: title)
        addMessage(message)
    }
    
    func addMessage(_ msg: String) {
        let msgInfo = XNUIMessageData(msg: msg)
        msgInfo.msgLength = msg.count
        msgInfo.msgSize = msg.lengthOfBytes(using: .utf8)
        messages.append(msgInfo)
    }
}
