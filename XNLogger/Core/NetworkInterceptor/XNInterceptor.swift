//
//  XNInterceptor.swift
//  XNLogger
//
//  Created by Sunil Sharma on 03/01/19.
//  Copyright © 2019 Sunil Sharma. All rights reserved.
//

import UIKit

internal class XNInterceptor: NSObject {
    
    /**
     Setup and start logging network calls.
     */
    func startInterceptingNetwork() {
        /// Before swizzle checking if it's already not swizzled.
        /// If it already swizzled skip else swizzle for logging.
        /// This check make safe to call multiple times.
        if isProtocolSwizzled() == false {
            // Let cache URLSession protocol classes without Custom log URL protocol class.
            // So that later custom URL protocol can be disabled
            _ = URLSession.shared
            swizzleProtocolClasses()
        }
    }
    
    /**
     Stop intercepting network calls and revert back changes made to
     intercept network calls.
     */
    func stopInterceptingNetwork() {
        /// Check if already unswizzled for logging, if so then skip
        /// else unswizzle for logging i.e. it will stop logging.
        /// Check make it safe to call multiple times.
        if isProtocolSwizzled() {
            swizzleProtocolClasses()
        }
    }
    
    func isProtocolSwizzled() -> Bool {
        let protocolClasses: [AnyClass] = URLSessionConfiguration.default.protocolClasses ?? []
        for protocolCls in protocolClasses {
            if protocolCls == XNURLProtocol.self {
                return true
            }
        }
        return false
    }
    
    func swizzleProtocolClasses() {
        let instance = URLSessionConfiguration.default
        if let uRLSessionConfigurationClass: AnyClass = object_getClass(instance),
            let originalProtocolGetter: Method = class_getInstanceMethod(uRLSessionConfigurationClass, #selector(getter: uRLSessionConfigurationClass.protocolClasses)),
            let customProtocolClass: Method = class_getInstanceMethod(URLSessionConfiguration.self, #selector(URLSessionConfiguration.xnProcotolClasses)) {
            method_exchangeImplementations(originalProtocolGetter, customProtocolClass)
        } else {
            print("XNL: Failed to swizzle protocol classes")
        }
    }
    
}

extension URLSessionConfiguration {
    
    /**
    Never call this method directly.
    Always use `protocolClasses` to get protocol classes.
    */
    @objc func xnProcotolClasses() -> [AnyClass]? {
        guard let xnlProcotolClasses = self.xnProcotolClasses() else {
            return []
        }
        var originalProtocolClasses = xnlProcotolClasses.filter {
            return $0 != XNURLProtocol.self
        }
        // Make sure XNURLProtocol class is at top in protocol classes list.
        originalProtocolClasses.insert(XNURLProtocol.self, at: 0)
        return originalProtocolClasses
    }
}
