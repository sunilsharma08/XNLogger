//
//  AppDelegate.swift
//  XNLoggerExample
//
//  Created by Sunil Sharma on 21/09/19.
//  Copyright © 2019 Sunil Sharma. All rights reserved.
//

import UIKit
import XNLogger

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        XNLogger.shared.startLogging()
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    //Optional XNLogger configuration
    func configureXNLogger() {
        // Start logging
        XNLogger.shared.startLogging()

        // Add predefined log handlers
        let consoleLogHandler = XNConsoleLogHandler.create()
        XNLogger.shared.addLogHandlers([consoleLogHandler])
        // Remove previously added handlers
        XNLogger.shared.removeHandlers([consoleLogHandler])

        // Stop logging
        XNLogger.shared.stopLogging()
    }

    // MARK: - Modern API Examples

    /// Example: Observe log events using AsyncStream
    func observeLogsWithAsyncStream() {
        Task {
            for await event in XNLogger.shared.logStream {
                switch event {
                case .request(let logData):
                    print("Request: \(logData.urlRequest.url?.absoluteString ?? "")")
                case .response(let logData):
                    print("Response: \(logData.urlRequest.url?.absoluteString ?? "")")
                }
            }
        }
    }

    /// Example: Observe log events using Combine
    /*
    import Combine
    var cancellables = Set<AnyCancellable>()

    func observeLogsWithCombine() {
        XNLogger.shared.logPublisher
            .sink { event in
                switch event {
                case .request(let logData):
                    print("Request: \(logData.urlRequest.url?.absoluteString ?? "")")
                case .response(let logData):
                    print("Response: \(logData.urlRequest.url?.absoluteString ?? "")")
                }
            }
            .store(in: &cancellables)
    }
    */

    /// Example: SwiftUI configuration
    /// When using .xnLoggerSheet() in SwiftUI, disable the UIKit shake gesture:
    ///
    /// ```
    /// XNUIManager.shared.startGesture = .none
    /// ```
    
}
