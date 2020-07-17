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
    lazy private var toolBarView: UIView = self.createToolbarView()
    
    private var isMiniModeActive: Bool {
        return XNUIManager.shared.isMiniModeActive
    }
    
    var appWindow: UIWindow? {
        return UIApplication.shared.delegate?.window as? UIWindow
    }
    
    override var safeAreaInsets: UIEdgeInsets {
        if isMiniModeActive {
            return .zero
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
        self.preservesSuperviewLayoutMargins = true
        self.layoutMargins = .zero
        self.clipsToBounds = true
        if #available(iOS 11.0, *) {
            self.directionalLayoutMargins = .zero
            self.insetsLayoutMarginsFromSafeArea = false
        } else {
            // Fallback on earlier versions
        }
        self.rootViewController = rootVC
        
        let presentTransition = CATransition()
        presentTransition.duration = 0.37
        presentTransition.timingFunction = CAMediaTimingFunction(name: .easeOut)
        presentTransition.type = .moveIn
        presentTransition.subtype = .fromTop
        self.layer.add(presentTransition, forKey: kCATransition)
        self.makeKeyAndVisible()
    }
    
    func dismiss() {
        
        self.appWindow?.makeKey()
        var animationDuration: TimeInterval = 0.37
        let isMiniModeActive = self.isMiniModeActive
        
        if isMiniModeActive {
            animationDuration = 0.2
        }
        UIView.animate(withDuration: animationDuration, delay: 0, options: [.curveEaseInOut], animations: {
            if isMiniModeActive {
                self.alpha = 0
            } else {
                self.frame.origin.y = self.frame.height
                self.alpha = 0.5
            }
        }) { (completed) in
            self.isHidden = true
            self.rootViewController = nil
        }
    }
    
    func enableMiniView() {
        addToolBar()
        let minViewWidth: CGFloat = UIScreen.main.bounds.width * 0.42
        let minViewHeight: CGFloat = UIScreen.main.bounds.height * 0.37
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0, options: [.beginFromCurrentState, .curveLinear], animations: {
            self.layer.cornerRadius = 10
            self.layer.borderWidth = 2
            self.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.5).cgColor
            self.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
            self.frame = CGRect(x: UIScreen.main.bounds.width - minViewWidth - 20, y: 90, width: minViewWidth, height: minViewHeight)
        }, completion: nil)
    }
    
    func enableFullScreenView() {
        self.toolBarView.removeFromSuperview()
        
        UIView.animate(withDuration: 0.3) {
            self.layer.cornerRadius = 0
            self.layer.borderWidth = 0
            self.layer.borderColor = nil
            self.transform = .identity
            self.frame = UIScreen.main.bounds
        }
    }
    
    func createToolbarView() -> UIView {
        print(#function)
        let toolView = UIView()
        toolView.backgroundColor = .lightGray
        
        let toolStackView = UIStackView()
        toolStackView.axis = .horizontal
        toolStackView.distribution = .fillEqually
        toolStackView.spacing = 1.0
        toolStackView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        toolView.addSubview(toolStackView)
        
        
        func toolbarButton(imageName: String, orientation: UIImage.Orientation? = nil) -> UIButton {
            let button = UIButton(type: .custom)
            button.backgroundColor = .white
            button.imageView?.contentMode = .scaleAspectFit
            var image = UIImage(named: imageName, in: Bundle.current(), compatibleWith: nil)
            if let imgOrientation = orientation, let cgEditImg = image?.cgImage {
                image = UIImage(cgImage: cgEditImg, scale: CGFloat(1), orientation: imgOrientation).withRenderingMode(.alwaysTemplate)
            }
            button.setImage(image, for: .normal)
            return button
        }
        
        let resizeBtn = toolbarButton(imageName: "resize")
        resizeBtn.addTarget(self, action: #selector(clickedOnResize(_:)), for: .touchUpInside)
        toolStackView.addArrangedSubview(resizeBtn)
        let moveBtn = toolbarButton(imageName: "move")
        moveBtn.addTarget(self, action: #selector(clickedOnMove(_:)), for: .touchUpInside)
//        moveBtn.imageEdgeInsets = UIEdgeInsets(top: 3, left: 3, bottom: 3, right: 3)
        toolStackView.addArrangedSubview(moveBtn)
        let moreOptionBtn = toolbarButton(imageName: "menu", orientation: .right)
        moreOptionBtn.imageEdgeInsets = UIEdgeInsets(top: 9, left: 9, bottom: 9, right: 9)
        moreOptionBtn.addTarget(self, action: #selector(clickedOnMoreOption(_:)), for: .touchUpInside)
        toolStackView.addArrangedSubview(moreOptionBtn)
        
        let topLineView = UIView()
        topLineView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.7)
        topLineView.autoresizingMask = [.flexibleWidth]
        topLineView.frame.size.height = 1
        toolView.addSubview(topLineView)
        
        return toolView
    }
    
    func addToolBar() {
        
        self.addSubview(toolBarView)
        
        toolBarView.translatesAutoresizingMaskIntoConstraints = false
        toolBarView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0).isActive = true
        toolBarView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0).isActive = true
        toolBarView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0).isActive = true
        var tabbarHeight: CGFloat = 0
        if let tabbarVC = self.rootViewController as? UITabBarController {
            if #available(iOS 11.0, *) {
                tabbarHeight = tabbarVC.tabBar.frame.height - super.safeAreaInsets.bottom
            }
            print("Height = \(tabbarHeight)")
        }
        toolBarView.heightAnchor.constraint(equalToConstant: tabbarHeight).isActive = true
        
    }
    
    @objc func clickedOnResize(_ sender: UIButton) {
        
    }
    
    @objc func clickedOnMove(_ sender: UIButton) {
        
    }
    
    @objc func clickedOnMoreOption(_ sender: UIButton) {
        
         let popoverVC = XNUIPopOverViewController()
        popoverVC.popoverPresentationController?.permittedArrowDirections = [.down]
        var optionItems: [XNUIOptionItem] = [
             XNUIOptionItem(title: "Logs", type: .logsScreen),
             XNUIOptionItem(title: "Settings", type: .settingsScreen)
         ]
        
        if let tabbarVC = self.rootViewController as? UITabBarController, let selectedVC = tabbarVC.selectedViewController {
            
            if let navVC = selectedVC as? UINavigationController, let rootVC = navVC.viewControllers.first, rootVC is XNUILogListVC {
                optionItems[0].isSelected = true
            }
            
            if selectedVC is XNUISettingsVC {
                optionItems[1].isSelected = true
            }
        }
        popoverVC.items = optionItems
        popoverVC.delegate = self
        popoverVC.popoverPresentationController?.sourceView = sender

        self.rootViewController?.present(popoverVC, animated: true, completion: nil)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let touchPoint = touch.location(in: self)
            self.touchStart = touchPoint
            currentEdges.reset()
            
            if touchPoint.y > self.bounds.minY + edgePadding && touchPoint.y < self.bounds.maxY - edgePadding && touchPoint.x > self.bounds.minX + edgePadding && touchPoint.x < self.bounds.maxX - edgePadding {
                currentEdges.center = true
                print("Middle")
                return
            }
            
            // Top
            if touchPoint.y > self.bounds.minY - edgePadding && touchPoint.y < self.bounds.minY + edgePadding {
                currentEdges.top = true
                print("Top")
            }
            
            // Bottom
            if touchPoint.y > self.bounds.maxY - edgePadding && touchPoint.y < self.bounds.maxY + edgePadding {
                currentEdges.bottom = true
                print("Bottom")
            }
            
            // Left
            if touchPoint.x > self.bounds.minX - edgePadding && touchPoint.x < self.bounds.minX + edgePadding {
                currentEdges.left = true
                print("Left")
            }
            
            // Right
            if touchPoint.x > self.bounds.maxX - edgePadding && touchPoint.x < self.bounds.maxX + edgePadding {
                currentEdges.right = true
                print("Right")
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
                print("Middle move")
                newRect.origin = CGPoint(x: curFrame.origin.x + deltaX, y: curFrame.origin.y + deltaY)
                self.frame.origin = newRect.origin
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
            
            UIView.animate(withDuration: 0.2, delay: 0, options: [.curveLinear], animations: {
                self.frame = newRect
            }, completion: nil)
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

extension XNUIWindow: XNUIPopoverDelegate {
    func popover(_ popover: XNUIPopOverViewController, didSelectItem item: XNUIOptionItem, indexPath: IndexPath) {
        popover.dismiss(animated: false, completion: nil)
        guard let tabbarVC = self.rootViewController as? UITabBarController else { return }
        if item.type == .logsScreen {
            tabbarVC.selectedIndex = 0
        } else if item.type == .settingsScreen {
            tabbarVC.selectedIndex = 1
        }
    }
}
