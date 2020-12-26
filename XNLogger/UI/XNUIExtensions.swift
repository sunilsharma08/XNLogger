//
//  XNUIExtensions.swift
//  XNLogger
//
//  Created by Sunil Sharma on 22/08/19.
//  Copyright © 2019 Sunil Sharma. All rights reserved.
//

import Foundation
import UIKit

extension UIWindow {
    
    override open func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        
        if XNUIManager.shared.startGesture == .shake,
            motion == .motionShake {
            XNUIManager.shared.presentUI()
        } else {
            super.motionEnded(motion, with: event)
        }
    }
}

extension Bundle {
    
    class func current() -> Bundle {
        return Bundle(for: XNUIManager.self)
    }
    
}

extension UIStoryboard {
    
    class func mainStoryboard() -> UIStoryboard {
        return UIStoryboard(name: "XNUIMain", bundle: Bundle.current())
    }
    
    func instantiateViewController<T: UIViewController>(ofType _: T.Type, withIdentifier identifier: String? = nil) -> T {
        let identifier = identifier ?? String(describing: T.self)
        if let viewController = instantiateViewController(withIdentifier: identifier) as? T {
            return viewController
        } else {
            fatalError("Failed to load ViewController with identifier \(identifier) from storyboard")
        }
    }
    
}

extension UITableViewCell: NibLoadableView, ReusableView {}

extension UITableViewHeaderFooterView: NibLoadableView, ReusableView {
    
}

extension UITableView {
    /**
     Use when xib and class name is same.
     */
    func register<T: UITableViewCell>(ofType _: T.Type) {
        let bundle = Bundle(for: T.self)
        let nib = UINib(nibName: T.nibName, bundle: bundle)
        register(nib, forCellReuseIdentifier: T.defaultReuseIdentifier)
    }
    
    func registerForHeaderFooterView<T: UITableViewHeaderFooterView>(ofType _: T.Type) {
        let bundle = Bundle(for: T.self)
        let nib = UINib(nibName: T.nibName, bundle: bundle)
        register(nib, forHeaderFooterViewReuseIdentifier: T.defaultReuseIdentifier)
    }
    
    func dequeueReusableCell<T: UITableViewCell>(for indexPath: IndexPath) -> T {
        
        guard let cell = dequeueReusableCell(withIdentifier: T.defaultReuseIdentifier, for: indexPath) as? T else {
            fatalError("Could not dequeue cell with identifier: \(T.defaultReuseIdentifier)")
        }
        return cell
    }
}

extension String {
    
    public func heightWithConstrainedWidth(_ width: CGFloat, font: UIFont, options: NSStringDrawingOptions = [.usesLineFragmentOrigin, .usesFontLeading]) -> CGSize {
        let constraintRect = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: options, attributes: [NSAttributedString.Key.font: font], context: nil)
        return boundingBox.size
    }
    
    public func widthWithConstrainedHeight(_ height: CGFloat, font: UIFont, options: NSStringDrawingOptions = [.usesLineFragmentOrigin, .usesFontLeading]) -> CGSize {
        let constraintRect = CGSize(width: CGFloat.greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: options, attributes: [NSAttributedString.Key.font: font], context: nil)
        return boundingBox.size
    }
    
}

extension NSNotification.Name {
    static let logDataUpdate = NSNotification.Name("com.xnLogger.logDataUpdateNotification")
}

extension UIEdgeInsets {
    
    init(inset: CGFloat) {
        self.init()
        top = inset
        bottom = inset
        left = inset
        right = inset
    }
}

extension UIView {
    /**
     Add constraints to current view to match with given another view with specified margin.
     
     Another view can be parent or child of current view.
     
     - Parameter pView: View to match current view.
     - Parameter margin: Margin between current view and the other view
     */
    func match(to pView: UIView, margin: CGFloat) {
        self.leadingAnchor.constraint(equalTo: pView.leadingAnchor, constant: margin).isActive = true
        self.trailingAnchor.constraint(equalTo: pView.trailingAnchor, constant: margin).isActive = true
        self.topAnchor.constraint(equalTo: pView.topAnchor, constant: margin).isActive = true
        self.bottomAnchor.constraint(equalTo: pView.bottomAnchor, constant: margin).isActive = true
    }
}

extension DispatchQueue {
    func safeAsync(_ block: @escaping ()->()) {
        if self === DispatchQueue.main && Thread.isMainThread {
            block()
        } else {
            async { block() }
        }
    }
}

extension CGRect: Comparable {
    
    public static func == (lhs: CGRect, rhs: CGRect) -> Bool {
        return lhs.width == rhs.width && lhs.width == rhs.width
    }
    
    public static func < (lhs: CGRect, rhs: CGRect) -> Bool {
        return lhs.width < rhs.width && lhs.width < rhs.width
    }
}
