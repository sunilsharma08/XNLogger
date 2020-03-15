//
//  XNUIExtensions.swift
//  XNLogger
//
//  Created by Sunil Sharma on 22/08/19.
//  Copyright © 2019 Sunil Sharma. All rights reserved.
//

import Foundation

extension UIWindow {
    
    override open func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        
        if XNUIManager.shared.startGesture == .shake,
            motion == .motionShake {
            XNUIManager.shared.presentNetworkLogUI()
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

extension UIView {
}

extension String {
    public func heightWithConstrainedWidth(_ width: CGFloat, font: UIFont, options: NSStringDrawingOptions = [.usesLineFragmentOrigin, .usesFontLeading]) -> CGFloat {
        let constraintRect = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: options, attributes: [NSAttributedString.Key.font: font], context: nil)
        return boundingBox.height
    }
}
