//
//  XNUIHelper.swift
//  XNLogger
//
//  Created by Sunil Sharma on 17/08/19.
//  Copyright © 2019 Sunil Sharma. All rights reserved.
//

import Foundation
import UIKit

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
    static let navTint: UIColor = UIColor.white
}

final class XNUIConstants {
    static let messageFont: UIFont = UIFont.systemFont(ofSize: 15)
    static let msgCellMaxLength: Int = Int(UIScreen.main.bounds.height * 3)
    static let msgCellMaxCharCount: Int = Int(UIScreen.main.bounds.width * 0.05 * UIScreen.main.bounds.height * 0.1)
    static let msgCellMaxAllowedSize: Int = 100000
    static let activityIndicatorTag: Int = 10263
    static let logIdKey: String = "logIdentifier"
    static let isResponseLogUpdate: String = "isResponseLogUpdate"
    static let txtLogFileName: String = "XNLogger-log-%@.txt"
}

class XNUIHelper {
    
    func randomString(length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyz0123456789"
        return String((0..<length).map{ _ in letters.randomElement() ?? "x" })
    }
    
    func showError(on: UIViewController, title: String = "Error", message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "Ok", style: .default) { (action) in
            alertController.dismiss(animated: true, completion: nil)
        }
        
        alertController.addAction(okAction)
        on.present(alertController, animated: true, completion: nil)
    }
    
    func showActivityIndicator(on view: UIView) {
        if let _ = view.viewWithTag(XNUIConstants.activityIndicatorTag) as? UIActivityIndicatorView {
            return
        }
        
        view.isUserInteractionEnabled = false
        let containerView = UIView()
        containerView.backgroundColor = UIColor.gray.withAlphaComponent(0.7)
        containerView.frame.size = CGSize(width: 75, height: 75)
        containerView.clipsToBounds = true
        containerView.layer.cornerRadius = 10
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        let activityIndicatorView = UIActivityIndicatorView(style: .whiteLarge)
        activityIndicatorView.tag = XNUIConstants.activityIndicatorTag
        activityIndicatorView.hidesWhenStopped = true
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(activityIndicatorView)
        view.addSubview(containerView)
        
        containerView.widthAnchor.constraint(equalToConstant: containerView.frame.width).isActive = true
        containerView.heightAnchor.constraint(equalToConstant: containerView.frame.height).isActive = true
        activityIndicatorView.widthAnchor.constraint(equalToConstant: activityIndicatorView.frame.width).isActive = true
        activityIndicatorView.heightAnchor.constraint(equalToConstant: activityIndicatorView.frame.height).isActive = true
        
        containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        activityIndicatorView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
        activityIndicatorView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        containerView.layoutIfNeeded()
        view.bringSubviewToFront(containerView)
        activityIndicatorView.startAnimating()
    }
    
    func hideActivityIndicator(from view: UIView) {
        view.isUserInteractionEnabled = true
        if let activityIndicatorView = view.viewWithTag(XNUIConstants.activityIndicatorTag) as? UIActivityIndicatorView,
            let activityIndicatorSuperView = activityIndicatorView.superview {
            activityIndicatorView.stopAnimating()
            activityIndicatorSuperView.removeFromSuperview()
        }
    }
    
    func createNavButton(imageName: String, imageInsets: UIEdgeInsets = .zero) -> UIButton {
        
        let customButton = UIButton(type: .custom)
        customButton.tintColor = UIColor(red: 239/255.0, green: 239/255.0, blue: 239/255.0, alpha: 1)
        customButton.adjustsImageWhenHighlighted = false
        customButton.imageView?.contentMode = .scaleAspectFit
        customButton.imageEdgeInsets = imageInsets
        customButton.setImage(UIImage(named: imageName, in: Bundle.current(), compatibleWith: nil), for: .normal)
        
        return customButton
    }
    
    func getWindow() -> UIWindow? {
        for window in UIApplication.shared.windows {
            if window is XNUIWindow {
                return window
            }
        }
        return nil
    }
    
    func getVersion() -> String {
        if let sdkVersion = Bundle.current().infoDictionary?["CFBundleShortVersionString"] as? String {
            return sdkVersion
        }
        return "Uknown"
    }
    
    func swizzleKeyCommands() {
        let windowClass: AnyClass = UIApplication.self
        if let keyCommandsGetter: Method = class_getInstanceMethod(windowClass, #selector(getter: windowClass.keyCommands)),
            let customKeyCommandGetter: Method = class_getInstanceMethod(UIApplication.self, #selector(UIApplication.handleKeyCommands)) {
            method_exchangeImplementations(keyCommandsGetter, customKeyCommandGetter)
        } else {
            print("XNL: Failed to swap UIKeyCommands")
        }
    }
}

class XNUIFileService {
    
    func getLogsDirectory() -> URL? {
        
        if var cacheURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first {
            cacheURL = cacheURL.appendingPathComponent("XNLogger/NetworkLogs")
            if FileManager.default.fileExists(atPath: cacheURL.path) {
                return cacheURL
            } else {
                do {
                    try FileManager.default.createDirectory(at: cacheURL, withIntermediateDirectories: true, attributes: nil)
                    return cacheURL
                } catch let error as NSError {
                    print("XNLogger: Failed to create 'XNLogger/NetworkLogs' directory - \(error.debugDescription)")
                }
            }
        }
        return nil
    }
    
    func getLogFileName(for logId: String) -> String {
        return "XNLog-\(logId).dat"
    }
    
    /**
     Save log data(XNLogData) on disk.
     */
    func saveLogsDataOnDisk(_ logData: XNLogData, completion: (() -> Void)?) {
        
        DispatchQueue.global(qos: .userInitiated).async {
            if let logDirPath = self.getLogsDirectory() {
                let logFileURL = logDirPath.appendingPathComponent(self.getLogFileName(for: logData.identifier))
                NSKeyedArchiver.archiveRootObject(logData, toFile: logFileURL.path)
            }
            completion?()
        }
    }
    
    /**
     Remove log file of given log id
     */
    func removeLog(_ logId: String) {
        
        if let logsDirURL = self.getLogsDirectory() {
            let fileURL = logsDirURL.appendingPathComponent(self.getLogFileName(for: logId))
            do {
                try FileManager.default.removeItem(at: fileURL)
            } catch let error as NSError {
                print("XNLogger: Error while deleting file \(self.getLogFileName(for: logId)) - \(error.debugDescription)")
            }
        }
    }
    
    /**
     Remove logs directory
     */
    func removeLogDirectory() {
        
        if let logsDir = self.getLogsDirectory() {
            try? FileManager.default.removeItem(at: logsDir)
        }
    }
    
    func getLogData(for logId: String, completion: @escaping (_ logData: XNLogData?) -> Void) {
        
        DispatchQueue.global(qos: .userInteractive).async {
            if let logDirPath = self.getLogsDirectory() {
                let logFileURL = logDirPath.appendingPathComponent(self.getLogFileName(for: logId))
                let logData = NSKeyedUnarchiver.unarchiveObject(withFile: logFileURL.path) as? XNLogData
                DispatchQueue.main.safeAsync {
                    completion(logData)
                }
            }
        }
    }
    
    func getTempDirectory() -> URL? {
        let tempDirUrl = URL(fileURLWithPath: NSTemporaryDirectory(),
                             isDirectory: true).appendingPathComponent("XNLogger/Multimedia")
        if FileManager.default.fileExists(atPath: tempDirUrl.path) {
            return tempDirUrl
        } else {
            do {
                try FileManager.default.createDirectory(at: tempDirUrl, withIntermediateDirectories: true, attributes: nil)
                return tempDirUrl
            } catch let error as NSError {
                print("XNLogger: Failed to create 'XNLogger/Multimedia' directory - \(error.debugDescription)")
            }
        }
        return nil
    }
    
    func writeMedia(data: Data, ext: String, completion: @escaping (_ fileURL: URL?) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {[weak self] in
            guard let self = self else { return }
            
            if let tempUrl = self.getTempDirectory() {
                let fileUrl = tempUrl.appendingPathComponent("\(UUID().uuidString).\(ext)")
                try? data.write(to: fileUrl)
                completion(fileUrl)
            } else {
                completion(nil)
            }
        }
    }
    
    func removeFile(url: URL) {
        try? FileManager.default.removeItem(at: url)
    }
}
