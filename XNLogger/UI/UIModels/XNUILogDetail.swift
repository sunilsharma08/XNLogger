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
    var msgHeight: Float = 0
    
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
    
    convenience init(title: String, message: String, maxWidth: Float) {
        self.init(title: title)
        addMessage(message, maxWidth: maxWidth)
    }
    
    func addMessage(_ msg: String, maxWidth: Float) {
        let msgInfo = XNUIMessageData(msg: msg)
        msgInfo.msgHeight = Float(msg.heightWithConstrainedWidth(CGFloat(maxWidth), font: XNUIConstants.messageFont))
        messages.append(msgInfo)
    }
}
