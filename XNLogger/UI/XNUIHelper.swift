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
    func saveLogsDataOnDisk(_ logData: XNLogData) {
        
        DispatchQueue.global(qos: .default).async {
            if let logDirPath = self.getLogsDirectory() {
                let logFileURL = logDirPath.appendingPathComponent(self.getLogFileName(for: logData.identifier))
                NSKeyedArchiver.archiveRootObject(logData, toFile: logFileURL.path)
            }
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
            do {
                try FileManager.default.removeItem(at: logsDir)
            } catch let error as NSError {
                print("XNLogger: Error while deleting logs directory - \(error.debugDescription)")
            }
        }
    }
    
    func getLogData(for logId: String, completion: @escaping (_ logData: XNLogData?) -> Void) {
        
        DispatchQueue.global(qos: .userInteractive).async {
            if let logDirPath = self.getLogsDirectory() {
                let logFileURL = logDirPath.appendingPathComponent(self.getLogFileName(for: logId))
                let logData = NSKeyedUnarchiver.unarchiveObject(withFile: logFileURL.path) as? XNLogData
                DispatchQueue.main.async {
                    completion(logData)
                }
            }
        }
    }
    
    func getTempDirectory() -> URL? {
        let tempDirUrl = URL(fileURLWithPath: NSTemporaryDirectory(),
                             isDirectory: true).appendingPathComponent("Multimedia")
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
    
    func writeMedia(data: Data, completion: () -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            if let tempUrl = self.getTempDirectory() {
                let fileUrl = tempUrl.appendingPathComponent(UUID().uuidString)
                data.sniffMimeEnum()
            }
        }
    }
    
}
