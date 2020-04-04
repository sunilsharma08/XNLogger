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
    static let status1xx: UIColor = UIColor(red: 51/255.0, green: 153/255.0, blue: 1, alpha: 1)
    static let status2xx: UIColor = UIColor(red: 42/255.0, green: 201/255.0, blue: 64/255.0, alpha: 1)
    static let status3xx: UIColor = UIColor(red: 150/255.0, green: 80/255.0, blue: 238/255.0, alpha: 1)
    static let status4xx: UIColor = UIColor(red: 1, green: 127/255.0, blue: 0, alpha: 1)
    static let status5xx: UIColor = UIColor(red: 1, green: 69/255.0, blue: 0, alpha: 1)
    static let running: UIColor = UIColor(red: 51/255.0, green: 153/255.0, blue: 1, alpha: 1)
    static let cancelled: UIColor = UIColor(red: 1, green: 127/255.0, blue: 0, alpha: 1)
    static let unknown: UIColor = UIColor(red: 105/255.0, green: 112/255.0, blue: 159/255.0, alpha: 1)
    static let suspended: UIColor = UIColor(red: 1, green: 183/255.0, blue: 15/255.0, alpha: 1)
}

struct XNUIAppColor {
    
    static let primary: UIColor = UIColor(red: 1, green: 95/255.0, blue: 88/255.0, alpha: 1)
    static let lightPrimary: UIColor = UIColor(red: 1, green: 147/255.0, blue: 133/255.0, alpha: 1)
    static let title: UIColor = UIColor(red: 48/255.0, green: 48/255.0, blue: 48/255.0, alpha: 1)
    static let subtitle: UIColor = UIColor(red: 130/255.0, green: 130/255.0, blue: 130/255.0, alpha: 1)
    static let navLogo: UIColor = UIColor.white
    static let navTint: UIColor = UIColor.white
}

final class XNUIConstants {
    static let logDataUpdtNotificationName = NSNotification.Name(rawValue: "com.xnLogger.logDataUpdateNotification")
    static let messageFont: UIFont = UIFont.systemFont(ofSize: 15)
    static let msgCellMaxLength: Int = Int(UIScreen.main.bounds.height * 3)
    static let msgCellMaxCharCount: Int = Int(UIScreen.main.bounds.width * 0.05 * UIScreen.main.bounds.height * 0.1)
    static let msgCellMaxAllowedSize: Int = 200000
    
}

class XNUIHelper {
    
}
