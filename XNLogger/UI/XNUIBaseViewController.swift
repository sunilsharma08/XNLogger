//
//  XNUIBaseTabBarController.swift
//  XNLogger
//
//  Created by Sunil Sharma on 23/08/19.
//  Copyright © 2019 Sunil Sharma. All rights reserved.
//

import UIKit

@MainActor protocol XNUIViewModeDelegate: AnyObject {
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
        let isMiniMode = XNUIManager.shared.isMiniModeActive
        self.tabBarController?.tabBar.isHidden = isMiniMode
        self.extendedLayoutIncludesOpaqueBars = isMiniMode
        if isMiniMode {
            self.edgesForExtendedLayout = .all
            let toolbarHeight = miniModeToolbarHeight()
            self.additionalSafeAreaInsets.bottom = toolbarHeight
        }
        XNUIManager.shared.viewModeDelegate = self
    }

    func miniModeToolbarHeight() -> CGFloat {
        let tabBarHeight = self.tabBarController?.tabBar.frame.height ?? 0
        let realSafeAreaBottom = XNUIManager.shared.logWindow?.appWindow?.safeAreaInsets.bottom ?? 0
        return tabBarHeight - realSafeAreaBottom
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
            self.extendedLayoutIncludesOpaqueBars = true
            self.edgesForExtendedLayout = .all
            self.additionalSafeAreaInsets.bottom = miniModeToolbarHeight()
            self.headerView?.addGestureRecognizer(panGesture)
        } else {
            self.tabBarController?.tabBar.isHidden = false
            self.extendedLayoutIncludesOpaqueBars = false
            self.additionalSafeAreaInsets.bottom = 0
            self.headerView?.removeGestureRecognizer(panGesture)
        }
        self.view.endEditing(true)
    }
}

