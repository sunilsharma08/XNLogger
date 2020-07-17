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
