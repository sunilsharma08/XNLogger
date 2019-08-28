//
//  NLUILogDetailViewController.swift
//  NetworkLogger
//
//  Created by Sunil Sharma on 27/08/19.
//  Copyright © 2019 Sunil Sharma. All rights reserved.
//

import UIKit

class NLUILogDetailVC: NLUIBaseViewController {
    
    class func instance() -> NLUILogDetailVC? {
        
        let controller = NLUILogDetailVC(nibName: String(describing: self), bundle: Bundle.current())
        return controller
    }

    var logData: NLLogData?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViews()
    }
    
    func configureViews() {
        self.navigationItem.title = "Log details"
    }

}
