//
//  XNUIWindow.swift
//  XNLogger
//
//  Created by Sunil Sharma on 22/06/20.
//  Copyright © 2020 Sunil Sharma. All rights reserved.
//

import UIKit

fileprivate struct XNUITouchEdges {
    
    var top: Bool = false
    var left: Bool = false
    var bottom: Bool = false
    var right: Bool = false
    var center: Bool = false
    
    mutating func reset() {
        top = false
        left = false
        bottom = false
        right = false
        center = false
    }
}

class XNUIWindow: UIWindow {
    
    fileprivate var currentEdges: XNUITouchEdges = XNUITouchEdges()
    var touchStart: CGPoint = .zero
    let edgePadding: CGFloat = 20
    
    var isMiniModeActive: Bool = false
    
    var appWindow: UIWindow? {
        return UIApplication.shared.delegate?.window as? UIWindow
    }
    
    override var safeAreaInsets: UIEdgeInsets {
        if isMiniModeActive {
            return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        } else {
            if #available(iOS 11.0, *) {
                return super.safeAreaInsets
            } else {
                return UIEdgeInsets(top: 64, left: 0, bottom: 0, right: 0)
            }
        }
    }
    
    func present(rootVC: UIViewController) {
        
        self.windowLevel = .init(CGFloat.greatestFiniteMagnitude)
        self.layoutMargins = .zero
        self.preservesSuperviewLayoutMargins = true
        self.layoutMargins = .zero
        if #available(iOS 11.0, *) {
            self.directionalLayoutMargins = .zero
            self.insetsLayoutMarginsFromSafeArea = false
        } else {
            // Fallback on earlier versions
        }
        self.rootViewController = rootVC
        UIView.animate(withDuration: 0.25) {
            self.makeKeyAndVisible()
        }
    }
    
    func dismiss() {
        self.isHidden = true
        self.appWindow?.makeKey()
        self.rootViewController = nil
    }
    
    func activateMiniView() {
        self.layer.cornerRadius = 10
        self.layer.borderWidth = 2
        self.layer.borderColor = UIColor.lightGray.cgColor
        self.clipsToBounds = true
        self.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
    }
    
    func returnFullView() {
        self.transform = CGAffineTransform(scaleX: 1, y: 1)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let touchPoint = touch.location(in: self)
            self.touchStart = touchPoint
            currentEdges.reset()
            
            if touchPoint.y > self.bounds.minY + edgePadding && touchPoint.y < self.bounds.maxY - edgePadding && touchPoint.x > self.bounds.minX + edgePadding && touchPoint.x < self.bounds.maxX - edgePadding {
                currentEdges.center = true
//                print("Middle")
                return
            }
            
            // Top
            if touchPoint.y > self.bounds.minY - edgePadding && touchPoint.y < self.bounds.minY + edgePadding {
                currentEdges.top = true
//                print("Top")
            }
            
            // Bottom
            if touchPoint.y > self.bounds.maxY - edgePadding && touchPoint.y < self.bounds.maxY + edgePadding {
                currentEdges.bottom = true
//                print("Bottom")
            }
            
            // Left
            if touchPoint.x > self.bounds.minX - edgePadding && touchPoint.x < self.bounds.minX + edgePadding {
                currentEdges.left = true
//                print("Left")
            }
            
            // Right
            if touchPoint.x > self.bounds.maxX - edgePadding && touchPoint.x < self.bounds.maxX + edgePadding {
                currentEdges.right = true
//                print("Right")
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first, touch.phase == .moved {
            
            let currentTouchPoint = touch.location(in: self)
            let preTouchPoint = touch.previousLocation(in: self)
            let deltaWidth = currentTouchPoint.x - preTouchPoint.x
            let deltaHeight = currentTouchPoint.y - preTouchPoint.y
            let deltaX = currentTouchPoint.x - self.touchStart.x
            let deltaY = currentTouchPoint.y - self.touchStart.y
            
            let curFrame = self.frame
            var newRect: CGRect = self.frame
            
            if currentEdges.center {
//                print("Middle move")
                newRect.origin = CGPoint(x: curFrame.origin.x + deltaX, y: curFrame.origin.y + deltaY)
//                self.frame.origin = newRect.origin
                return
            }
            
            if currentEdges.top {
                newRect.origin.y = curFrame.origin.y + deltaY
                newRect.size.height = curFrame.height - deltaY
            }
            
            if currentEdges.bottom {
                newRect.size.height = curFrame.height + deltaHeight
            }
            
            if currentEdges.left {
                newRect.origin.x = curFrame.origin.x + deltaX
                newRect.size.width = curFrame.width - deltaX
            }
            
            if currentEdges.right {
                newRect.size.width = curFrame.width + deltaWidth
            }
            
//            UIView.animate(withDuration: 0.2, delay: 0, options: [.curveLinear], animations: {
//                self.frame = newRect
//            }, completion: nil)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        print(#function)
        self.touchStart = .zero
        self.currentEdges.reset()
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.touchStart = .zero
        self.currentEdges.reset()
    }
}
