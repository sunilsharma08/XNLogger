//
//  XNUICustomPathUIActivity.swift
//  XNLogger
//
//  Created by Sunil Sharma on 06/09/20.
//  Copyright © 2020 Sunil Sharma. All rights reserved.
//

import Foundation
import UIKit

extension UIActivity.ActivityType {
    static let saveToPath = UIActivity.ActivityType("com.xnlogger.saveToPath")
    static let saveToDeskTop = UIActivity.ActivityType(rawValue: "com.xnlogger.saveToDesktop")
}

class XNUISimulatorActivity: UIActivity {
    
    var shareData: [Any] = []
    var destinationPath: String = ""
    
    override class  var activityCategory: UIActivity.Category {
        return .action
    }
    
    override func prepare(withActivityItems activityItems: [Any]) {
        shareData = activityItems
    }
    
    override func canPerform(withActivityItems activityItems: [Any]) -> Bool {
        #if targetEnvironment(simulator)
          return true
        #else
          return false
        #endif
    }
    
    override func perform() {
        
        let toBasePathUrl = URL(fileURLWithPath: destinationPath)
        var actionStatus: Bool = true
        let utils = XNUIHelper()
        
        for item in shareData {
            do {
                if let shareUrl = item as? URL {
                    var toPathUrl = toBasePathUrl
                    toPathUrl.appendPathComponent(shareUrl.lastPathComponent)
                    if FileManager.default.fileExists(atPath: toPathUrl.path) {
                        let fileName = "\(toPathUrl.deletingPathExtension().lastPathComponent)-\(utils.randomString(length: 5))"
                        let fileExtension = toPathUrl.pathExtension
                        toPathUrl.deleteLastPathComponent()
                        toPathUrl = toPathUrl.appendingPathComponent("\(fileName).\(fileExtension)")
                    }
                    try FileManager.default.copyItem(at: shareUrl, to: toPathUrl)
                    
                } else if let shareStr = item as? String {
                    
                    var toPathUrl = toBasePathUrl
                    toPathUrl.appendPathComponent(String(format: XNUIConstants.txtLogFileName, utils.randomString(length: 5)))
                    try shareStr.write(to: toPathUrl, atomically: true, encoding: String.Encoding.utf8)
                }
            } catch {
                actionStatus = false
            }
        }
        self.activityDidFinish(actionStatus)
    }
}

class XNUISaveToPathActivity: XNUISimulatorActivity {
    
    override var activityType: UIActivity.ActivityType? {
        return .saveToPath
    }

    override var activityTitle: String? {
        return "Save to Location"
    }

    override var activityImage: UIImage? {
        return UIImage(named: "saveToLocation", in: Bundle.current(), compatibleWith: nil)
    }
    
    override var activityViewController: UIViewController? {
        
        let alertVC = UIAlertController(title: "Save to location", message: nil, preferredStyle: .alert)
        alertVC.addTextField { (textField) in
            textField.placeholder = "Enter complete location path"
        }
        
        let actionSave = UIAlertAction(title: "Save", style: .default) {[weak self] (action) in
            guard let self = self else { return }
            
            if let pathTextField = alertVC.textFields?.first,
                let toPathStr = pathTextField.text, toPathStr.isEmpty == false {
                self.destinationPath = toPathStr
                self.perform()
            }
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            self.activityDidFinish(false)
        }
        
        alertVC.addAction(cancel)
        alertVC.addAction(actionSave)
        
        return alertVC
    }
    
}

class XNUISaveToDesktopActivity: XNUISimulatorActivity {
    
    override init() {
        super.init()
        let envInfo = ProcessInfo.processInfo.environment
        if var homePath = envInfo["SIMULATOR_HOST_HOME"] {
            homePath += "/Desktop"
            destinationPath = homePath
        } else {
            destinationPath = ""
        }
    }
    
    override var activityType: UIActivity.ActivityType? {
        return .saveToDeskTop
    }

    override var activityTitle: String? {
        return "Save to Desktop"
    }
    
    override var activityImage: UIImage? {
        return UIImage(named: "saveToDesktop", in: Bundle.current(), compatibleWith: nil)
    }
}
