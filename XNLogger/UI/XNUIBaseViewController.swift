//
//  XNUIBaseTabBarController.swift
//  XNLogger
//
//  Created by Sunil Sharma on 23/08/19.
//  Copyright © 2019 Sunil Sharma. All rights reserved.
//

import UIKit

class  XNUIBaseTabBarController: UITabBarController {
    
}

class XNUINavigationController: UINavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setNavigationBarHidden(true, animated: false)
    }
}

class XNUIBaseViewController: UIViewController {
    
    @IBOutlet weak var headerView: XNUIHeaderView?
    var helper: XNUIHelper = XNUIHelper()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        baseConfigureViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    func baseConfigureViews() {
        self.tabBarController?.tabBar.barTintColor = .white
        self.hidesBottomBarWhenPushed = true
        self.headerView?.backgroundColor = XNUIAppColor.primary
        self.headerView?.tintColor = XNUIAppColor.navTint
    }
}

