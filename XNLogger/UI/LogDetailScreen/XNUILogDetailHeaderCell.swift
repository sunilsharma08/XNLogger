//
//  XNUILogDetailHeaderCell.swift
//  XNLogger
//
//  Created by Sunil Sharma on 29/08/19.
//  Copyright © 2019 Sunil Sharma. All rights reserved.
//

import UIKit

class XNUILogDetailHeaderCell: UITableViewHeaderFooterView {

    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var showHideLbl: UILabel!

    func updateViews(with mesaage: String) {
        self.titleLbl.text = mesaage
    }
    
}
