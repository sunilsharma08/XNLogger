//
//  AppDelegate.swift
//  NetworkLogger
//
//  Created by Sunil Sharma on 14/12/18.
//  Copyright © 2018 Sunil Sharma. All rights reserved.
//

import UIKit
#if DEBUG
////import CocoaDebug
import netfox
#endif


//func print(_ items: Any..., separator: String = ", ", terminator: String = "\n") {
//}
//
//func Log(_ items: Any..., separator: String = ", ", terminator: String = "\n") {
//    let output = items.map { "\($0)" }.joined(separator: separator)
//    Swift.print(output, separator: separator, terminator: terminator)
//}


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
//        URLProtocol.registerClass(LogUrlProtocol.self)
//        URLProtocol.registerClass(CustomUrlProtocol.self)
        
        #if DEBUG
//        CocoaDebug.enable()
//        NFX.sharedInstance().start()
        #endif
        
        
        return true
    }
    
    // CocoaDebug method
    public func print<T>(file: String = #file, function: String = #function, line: Int = #line, _ message: T, color: UIColor = .white) {
//        #if DEBUG
//        swiftLog(file, function, line, message, color, false)
//        #endif
    }

}

