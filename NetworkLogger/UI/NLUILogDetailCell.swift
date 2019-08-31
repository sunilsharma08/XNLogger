//
//  NLUILogDetailCell.swift
//  NetworkLogger
//
//  Created by Sunil Sharma on 29/08/19.
//  Copyright © 2019 Sunil Sharma. All rights reserved.
//

import UIKit

class NLUILogDetailCell: UITableViewCell {
    
    @IBOutlet weak var logDetailMsg: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.logDetailMsg.textContainerInset = .zero
        self.logDetailMsg.textContainer.lineFragmentPadding = 0
    }
    
}
