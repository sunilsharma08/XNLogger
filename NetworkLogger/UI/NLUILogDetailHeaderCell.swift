//
//  NLUILogDetailHeaderCell.swift
//  NetworkLogger
//
//  Created by Sunil Sharma on 29/08/19.
//  Copyright © 2019 Sunil Sharma. All rights reserved.
//

import UIKit

class NLUILogDetailHeaderCell: UITableViewHeaderFooterView {

    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var showHideLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func updateViews(with mesaage: String) {
        self.titleLbl.text = mesaage
    }
    
}
