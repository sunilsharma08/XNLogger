//
//  XNUIManager.swift
//  Predicator
//
//  Created by Sunil Sharma on 21/08/19.
//  Copyright © 2019 Sunil Sharma. All rights reserved.
//

import Foundation
import UIKit

@objc
public enum XNGestureType: Int {
    case shake
    case custom
}

protocol XNUILogDataDelegate: class {
    func receivedLogData(_ logData: XNLogData, isResponse: Bool)
}

@objc
public final class XNUIManager: NSObject {
    
    @objc public static let shared: XNUIManager = XNUIManager()
    public var startGesture: XNGestureType? = .shake
    var uiLogHandler: XNUILogHandler = XNUILogHandler()
    var logsDataDict: [String: XNLogData] = [:]
    var logsIdArray: [String] = []
    
    private override init() {
        super.init()
        XNLogger.shared.addLogHandlers([uiLogHandler])
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
        
        if let presentingViewController = self.presentingViewController, !(presentingViewController is XNUIBaseTabBarController) {
            
            if let tabbarVC = UIStoryboard.mainStoryboard().instantiateViewController(withIdentifier: "nlMainTabBarController") as? UITabBarController {
                presentingViewController.present(tabbarVC, animated: true, completion: nil)
            }
        }
    }
    
    // Dismiss network logger UI
    @objc public func dismissNetworkUI() {
        
        if let presentingViewController = self.presentingViewController as? XNUIBaseTabBarController {
            presentingViewController.dismiss(animated: true, completion: nil)
        }
    }
    
    @objc public func clearLogs() {
        logsDataDict = [:]
        logsIdArray.removeAll()
    }
    
}

extension XNUIManager: XNUILogDataDelegate {
    
    func receivedLogData(_ logData: XNLogData, isResponse: Bool) {
        if isResponse == false {
            self.logsIdArray.append(logData.identifier)
        }
        self.logsDataDict[logData.identifier] = logData
        NotificationCenter.default.post(name: XNUIConstants.logDataUpdtNotificationName, object: nil, userInfo: nil)
    }
    
}
