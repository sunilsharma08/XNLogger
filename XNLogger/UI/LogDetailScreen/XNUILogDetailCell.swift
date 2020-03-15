//
//  XNUILogDetailCell.swift
//  XNLogger
//
//  Created by Sunil Sharma on 29/08/19.
//  Copyright © 2019 Sunil Sharma. All rights reserved.
//

import UIKit

class XNUILogDetailCell: UITableViewCell {
    
    @IBOutlet weak var logDetailMsg: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.logDetailMsg.textContainerInset = .zero
        self.logDetailMsg.textContainer.lineFragmentPadding = 0
        self.logDetailMsg.font = XNUIConstants.messageFont
        self.logDetailMsg.layoutManager.allowsNonContiguousLayout = true
    }
    
    func configureViews(_ messageData: XNUIMessageData) {
        self.logDetailMsg.layoutIfNeeded()
        self.logDetailMsg.text = messageData.message
        if messageData.msgLength > XNUIConstants.msgViewMaxLength {
            self.logDetailMsg.isScrollEnabled = true
        } else {
            self.logDetailMsg.isScrollEnabled = false
        }
    }
    
}
