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
        self.navigationBar.isTranslucent = false
        self.navigationBar.barTintColor = XNUIAppColor.theme
        self.navigationBar.tintColor = XNUIAppColor.navTint
        self.navigationBar.titleTextAttributes = [.foregroundColor: XNUIAppColor.navLogo]
    }
}

class XNUIBaseViewController: UIViewController {
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: XNUIAppColor.navLogo, .font: UIFont.systemFont(ofSize: 20, weight: .semibold)]
    }
}

