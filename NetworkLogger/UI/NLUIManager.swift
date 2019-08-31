//
//  NLUIManager.swift
//  Predicator
//
//  Created by Sunil Sharma on 21/08/19.
//  Copyright © 2019 Sunil Sharma. All rights reserved.
//

import Foundation
import UIKit

@objc
public enum NLGestureType: Int {
    case shake
    case custom
}

protocol NLUILogDataDelegate: class {
    func receivedLogData(_ logData: NLLogData, isResponse: Bool)
}

@objc
public final class NLUIManager: NSObject {
    
    @objc public static let shared: NLUIManager = NLUIManager()
    public var startGesture: NLGestureType? = .shake
    var uiLogHandler: NLUILogHandler = NLUILogHandler()
    var logsDataDict: [String: NLLogData] = [:]
    var logsIdArray: [String] = []
    
    private override init() {
        super.init()
        NetworkLogger.shared.addLogHandlers([uiLogHandler])
        self.uiLogHandler.delegate = self
    }
    
    // Return current root view controller
    private var presentingViewController: UIViewController? {
        var rootViewController = UIApplication.shared.keyWindow?.rootViewController
        while let controller = rootViewController?.presentedViewController {
            rootViewController = controller
        }
        return rootViewController
    }
    
    // Preset network logger UI to user. This is start point of UI
    @objc public func presentNetworkLogUI() {
        
        if let presentingViewController = self.presentingViewController, !(presentingViewController is NLUIBaseTabBarController) {
            
            if let tabbarVC = UIStoryboard.mainStoryboard().instantiateViewController(withIdentifier: "nlMainTabBarController") as? UITabBarController {
                presentingViewController.present(tabbarVC, animated: true, completion: nil)
            }
        }
    }
    
    // Dismiss network logger UI
    @objc public func dismissNetworkUI() {
        
        if let presentingViewController = self.presentingViewController as? NLUIBaseTabBarController {
            presentingViewController.dismiss(animated: true, completion: nil)
        }
    }
}

extension NLUIManager: NLUILogDataDelegate {
    
    func receivedLogData(_ logData: NLLogData, isResponse: Bool) {
        if isResponse == false {
            self.logsIdArray.append(logData.identifier)
        }
        self.logsDataDict[logData.identifier] = logData
        NotificationCenter.default.post(name: NLUIConstants.logDataUpdtNotificationName, object: nil, userInfo: nil)
    }
    
}
