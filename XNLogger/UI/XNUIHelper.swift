//
//  XNUIHelper.swift
//  XNLogger
//
//  Created by Sunil Sharma on 17/08/19.
//  Copyright © 2019 Sunil Sharma. All rights reserved.
//

import Foundation

protocol NibLoadableView: class {
    static var nibName: String { get }
}

extension NibLoadableView where Self: UIView {
    static var nibName: String {
        return String(describing: self)
    }
}

protocol ReusableView: class {
    static var defaultReuseIdentifier: String { get }
}

extension ReusableView where Self: UITableViewCell {
    static var defaultReuseIdentifier: String {
        return String(describing: self)
    }
}

extension ReusableView where Self: UITableViewHeaderFooterView {
    static var defaultReuseIdentifier: String {
        return String(describing: self)
    }
}

struct XNUIHTTPStatusColor {
    static let status2xx: UIColor = UIColor(red: 0.156, green: 0.854, blue: 0.066, alpha: 1)
    static let status4xx5xx: UIColor = UIColor(red: 1, green: 0.372, blue: 0.168, alpha: 1)
    static let status3xx: UIColor = UIColor(red: 0.6, green: 0.33, blue: 0.933, alpha: 1)
    static let running: UIColor = UIColor(red: 0.035, green: 0.764, blue: 1, alpha: 1)
    static let cancelled: UIColor = UIColor(red: 0.45, green: 0.45, blue: 0.45, alpha: 1)
}

struct XNUIAppColor {
    static let titleColor: UIColor = UIColor(red: 5/255.0, green: 24/255.0, blue: 42/255.0, alpha: 1)
    static let subtitleColor: UIColor = UIColor(red: 52/255.0, green: 73/255.0, blue: 94/255.0, alpha: 1)
}

final class XNUIConstants {
    static let logDataUpdtNotificationName = NSNotification.Name(rawValue: "com.networkLogger.logDataUpdateNotification")
}

class XNUIHelper {
    
}
