//
//  NLUILogDetail.swift
//  NetworkLogger
//
//  Created by Sunil Sharma on 29/08/19.
//  Copyright © 2019 Sunil Sharma. All rights reserved.
//

import Foundation

class NLUILogDetail {
    var title: String
    var messages: [String] = []
    var isExpended: Bool = false
    var shouldShowDataInFullScreen: Bool = false
    
    init(title: String) {
        self.title = title
    }
    
    convenience init(title: String, message: String?) {
        self.init(title: title)
        if let detail = message {
            self.messages.append(detail)
        }
    }
}
