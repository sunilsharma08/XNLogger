//
//  AppDelegate.swift
//  XNLoggerExample
//
//  Created by Sunil Sharma on 21/09/19.
//  Copyright © 2019 Sunil Sharma. All rights reserved.
//

import UIKit
import XNLogger

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        return true
    }
    
    //Optional XNLogger configuration
    func configureXNLogger() {
        // Start logging
        XNLogger.shared.startLogging()
        
        // Add predefined log handlers
        let consoleLogHandler = XNConsoleLogHandler.create()
        XNLogger.shared.addLogHandlers([consoleLogHandler])
        cl = XNRemo
        // Remove previously added handlers
        XNLogger.shared.removeHandlers([consoleLogHandler])
        
        // Stop logging
        XNLogger.shared.stopLogging()
    }
    
}
