//
//  XNUIOptionItem.swift
//  XNLogger
//
//  Created by Sunil Sharma on 10/07/20.
//  Copyright © 2020 Sunil Sharma. All rights reserved.
//

import UIKit

struct XNUIOptionItem {
    var title: String
    let type: XNUIOptionItemType
    var isSelected: Bool = false
    var font: UIFont = UIFont.systemFont(ofSize: 18)
}

enum XNUIOptionItemType {
    case shareResponse
    case shareRequest
    case shareReqtAndResp
    // Mini view mode options
    case logsScreen
    case settingsScreen
}

enum XNUISettingType {
    case startStopLog
    case logUnreadableRequest
    case logUnreadableResponse
    case clearData
    case version
    case help
}

class XNUISettingCategory {
    var title: String?
    var items: [XNUISettingItem] = []
    
    init() {
    }
    
    init(title: String) {
        self.title = title
    }
}

class XNUISettingItem {
    var title: String
    var subTitle: String?
    var textColor: UIColor = .black
    var type: XNUISettingType
    var value: Any?
    
    init(title: String, subTitle: String? = nil, type: XNUISettingType, value: Any? = nil) {
        self.title = title
        self.type = type
        self.subTitle = subTitle
        self.value = value
    }
}
