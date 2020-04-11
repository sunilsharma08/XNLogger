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
        self.selectionStyle = UITableViewCell.SelectionStyle.none
    }
    
    func configureViews(_ messageData: XNUIMessageData) {
        self.logDetailMsg.layoutIfNeeded()
        if messageData.showOnlyInFullScreen == false {
            
            self.logDetailMsg.textAlignment = .left
            self.logDetailMsg.isUserInteractionEnabled = true
            self.logDetailMsg.attributedText = nil
            self.logDetailMsg.text = messageData.message
            
            if messageData.msgCount > XNUIConstants.msgCellMaxCharCount {
                self.logDetailMsg.isScrollEnabled = true
            } else {
                if Int(messageData.message.heightWithConstrainedWidth(self.frame.width - 20, font: XNUIConstants.messageFont)) > XNUIConstants.msgCellMaxLength {
                    self.logDetailMsg.isScrollEnabled = true
                } else {
                    self.logDetailMsg.isScrollEnabled = false
                }
            }
        } else {
            
            self.logDetailMsg.isUserInteractionEnabled = false
            self.logDetailMsg.isScrollEnabled = false
            self.logDetailMsg.textAlignment = .center
            self.logDetailMsg.text = nil
            
            self.logDetailMsg.attributedText = getLargeMessage()
        }
    }
    
    func getLargeMessage() -> NSAttributedString {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        
        var msgAttributes = [NSAttributedString.Key.font: XNUIConstants.messageFont, .paragraphStyle: paragraphStyle, NSAttributedString.Key.foregroundColor: XNUIAppColor.subtitle]
        
        let largeDataMsg = NSMutableAttributedString(string: "\nData size is too big.\n", attributes: msgAttributes)
        msgAttributes[NSAttributedString.Key.foregroundColor] = UIColor(red: 0, green: 0, blue: 1, alpha: 1)
        largeDataMsg.append(NSAttributedString(string: "\nClick to view data.\n", attributes: msgAttributes))
        
        return largeDataMsg
    }
    
}
