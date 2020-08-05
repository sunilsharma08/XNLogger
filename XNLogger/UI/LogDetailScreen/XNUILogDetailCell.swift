//
//  XNUILogDetailCell.swift
//  XNLogger
//
//  Created by Sunil Sharma on 29/08/19.
//  Copyright © 2019 Sunil Sharma. All rights reserved.
//

import UIKit

class XNUILogTextView: UITextView {
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        
        // Disabling edit action menus for iOS 13 and above, as menu appear at wrong position for mini view mode
        // Need to fix.
        if #available(iOS 13.0, *), XNUIManager.shared.isMiniModeActive {
            return false
        }
        if action.description == "_define:" || action.description == "_lookup:" {
            return false
        }
        if action == #selector(selectAll) {
            
            if let range = selectedTextRange, range.start == beginningOfDocument, range.end == endOfDocument {
                return false // already selected all text
            }
            return !text.isEmpty
        }
        return super.canPerformAction(action, withSender: sender)
    }
}

class XNUILogDetailCell: UITableViewCell {
    
    @IBOutlet weak var logDetailMsg: XNUILogTextView!
    var indexPath: IndexPath?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.logDetailMsg.textContainerInset = .zero
        self.logDetailMsg.textContainer.lineFragmentPadding = 0
        self.logDetailMsg.font = XNUIConstants.messageFont
        self.logDetailMsg.layoutManager.allowsNonContiguousLayout = true
        self.selectionStyle = UITableViewCell.SelectionStyle.none
    }
    
    func configureViews(_ messageData: XNUIMessageData, indexPath: IndexPath) {
        self.logDetailMsg.layoutIfNeeded()
        self.indexPath = indexPath
        if messageData.showOnlyInFullScreen == false {
            
            if messageData.isEmptyDataMsg {
                self.logDetailMsg.textColor = XNUIAppColor.subtitle
            } else {
                self.logDetailMsg.textColor = .black
            }
            
            self.logDetailMsg.textAlignment = .left
            self.logDetailMsg.isUserInteractionEnabled = true
            self.logDetailMsg.attributedText = nil
            self.logDetailMsg.text = messageData.message
            
            if messageData.msgCount > XNUIConstants.msgCellMaxCharCount {
                self.logDetailMsg.isScrollEnabled = true
            } else {
                if Int(messageData.message.heightWithConstrainedWidth(self.frame.width - 20, font: XNUIConstants.messageFont).height) > XNUIConstants.msgCellMaxLength {
                    self.logDetailMsg.isScrollEnabled = true
                } else {
                    self.logDetailMsg.isScrollEnabled = false
                }
            }
            if logDetailMsg.isScrollEnabled {
                self.logDetailMsg.showsVerticalScrollIndicator = true
            } else {
                self.logDetailMsg.showsVerticalScrollIndicator = true
            }
        }
        else {
            
            self.logDetailMsg.isUserInteractionEnabled = false
            self.logDetailMsg.isScrollEnabled = false
            self.logDetailMsg.text = nil
            if messageData.data == nil {
                self.logDetailMsg.attributedText = getAttrString(title: "\nData size is too big.\n", subTitle: "\nClick to view data.\n")
            } else {
                let contentTypeName = messageData.fileMeta?.contentType.getName() ?? ""
                self.logDetailMsg.attributedText = getAttrString(title: "\nMultimedia data detected.\n(\(contentTypeName))\n", subTitle: "\nClick to preview data.\n")
            }
        }
    }
    
    func getAttrString(title: String, subTitle: String) -> NSAttributedString {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        
        var msgAttributes = [NSAttributedString.Key.font: XNUIConstants.messageFont, .paragraphStyle: paragraphStyle, NSAttributedString.Key.foregroundColor: XNUIAppColor.subtitle]
        
        let largeDataMsg = NSMutableAttributedString(string: title, attributes: msgAttributes)
        msgAttributes[NSAttributedString.Key.foregroundColor] = UIColor.systemBlue
        largeDataMsg.append(NSAttributedString(string: subTitle, attributes: msgAttributes))
        
        return largeDataMsg
    }
}
