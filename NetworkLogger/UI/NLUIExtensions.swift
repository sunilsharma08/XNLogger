//
//  NLUIExtensions.swift
//  NetworkLogger
//
//  Created by Sunil Sharma on 22/08/19.
//  Copyright © 2019 Sunil Sharma. All rights reserved.
//

import Foundation

extension UIWindow {
    
    override open func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        
        if NLUIManager.shared.startGesture == .shake,
            motion == .motionShake {
            NLUIManager.shared.presentNetworkLogUI()
        } else {
            super.motionEnded(motion, with: event)
        }
    }
}

extension Bundle {
    
    class func current() -> Bundle {
        return Bundle(for: NLUIManager.self)
    }
    
}
