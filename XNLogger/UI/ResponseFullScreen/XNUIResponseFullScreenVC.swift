//
//  XNUIResponseFullScreenVC.swift
//  XNLogger
//
//  Created by Sunil Sharma on 04/04/20.
//  Copyright © 2020 Sunil Sharma. All rights reserved.
//

import Foundation

class XNUIResponseFullScreenVC: XNUIBaseViewController {
    
    @IBOutlet weak var msgTextView: UITextView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var headerTitle: String!
    var logData: XNUIMessageData!
    
    class func controller(title: String, logData: XNUIMessageData) -> XNUIResponseFullScreenVC? {
        let controller = XNUIResponseFullScreenVC(nibName: String(describing: self), bundle: Bundle.current())
        controller.logData = logData
        controller.headerTitle = title
        return controller
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if msgTextView.text.isEmpty {
            loadData()
        }
    }
    
    func configureViews() {
        self.navigationItem.title = headerTitle
        self.activityIndicator.hidesWhenStopped = true
        self.msgTextView.text = nil
    }
    
    func loadData() {
        self.view.layoutIfNeeded()
        self.showActivityIndicator()
        self.msgTextView.text = logData.message
        self.hideActivityIndicator()
    }
    
    func showActivityIndicator() {
        activityIndicator.startAnimating()
    }
    
    func hideActivityIndicator() {
        activityIndicator.stopAnimating()
    }
}
