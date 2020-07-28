//
//  XNUIBaseTabBarController.swift
//  XNLogger
//
//  Created by Sunil Sharma on 23/08/19.
//  Copyright © 2019 Sunil Sharma. All rights reserved.
//

import UIKit

protocol XNUIViewModeDelegate: AnyObject {
    func viewModeDidChange(_ isMiniViewEnabled: Bool)
}

class  XNUIBaseTabBarController: UITabBarController {
    
}

class XNUINavigationController: UINavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setNavigationBarHidden(true, animated: false)
        self.interactivePopGestureRecognizer?.delegate = nil
    }
}

class XNUIBaseViewController: UIViewController {
    
    @IBOutlet weak var headerView: XNUIHeaderView?
    var helper: XNUIHelper = XNUIHelper()
    lazy var panGesture = UIPanGestureRecognizer(target: XNUIManager.shared.logWindow, action: #selector(XNUIManager.shared.logWindow?.clickedOnMove(_:)))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        baseConfigureViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = false
        XNUIManager.shared.viewModeDelegate = self
    }
    
    func baseConfigureViews() {
        self.tabBarController?.tabBar.tintColor = XNUIAppColor.primary
        self.extendedLayoutIncludesOpaqueBars = false
        self.tabBarController?.tabBar.isTranslucent = false
        self.headerView?.backgroundColor = XNUIAppColor.primary
        self.headerView?.tintColor = XNUIAppColor.navTint
        if XNUIManager.shared.isMiniModeActive {
            self.headerView?.addGestureRecognizer(panGesture)
        } else {
            self.headerView?.removeGestureRecognizer(panGesture)
        }
    }
}

extension XNUIBaseViewController: XNUIViewModeDelegate {
    
    @objc func viewModeDidChange(_ isMiniViewEnabled: Bool) {
        if isMiniViewEnabled {
            self.tabBarController?.tabBar.isHidden = true
            self.headerView?.addGestureRecognizer(panGesture)
        } else {
            self.tabBarController?.tabBar.isHidden = false
            self.headerView?.removeGestureRecognizer(panGesture)
        }
        self.view.endEditing(true)
    }
}

