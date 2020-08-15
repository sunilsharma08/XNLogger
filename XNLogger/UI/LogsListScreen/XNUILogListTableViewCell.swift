//
//  XNUILogListTableViewCell.swift
//  XNLogger
//
//  Created by Sunil Sharma on 23/08/19.
//  Copyright © 2019 Sunil Sharma. All rights reserved.
//

import UIKit

class XNUILogListTableViewCell: UITableViewCell {

    @IBOutlet weak var statusIcon: UIImageView!
    @IBOutlet weak var statusView: UIView!
    @IBOutlet weak var httpStatusLbl: UILabel!
    @IBOutlet weak var urlPathLbl: UILabel!
    @IBOutlet weak var httpMethodLbl: UILabel!
    @IBOutlet weak var requestStartTimeLbl: UILabel!
    @IBOutlet weak var requestDurationLbl: UILabel!
    @IBOutlet weak var bottomDividerView: UIView!
    let dateFormatter: DateFormatter = DateFormatter()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.urlPathLbl.textColor = XNUIAppColor.title
        self.httpMethodLbl.textColor = XNUIAppColor.subtitle
        self.requestStartTimeLbl.textColor = XNUIAppColor.subtitle
        self.requestDurationLbl.textColor = XNUIAppColor.subtitle
        self.dateFormatter.dateFormat = "hh:mm:ss a"
        self.httpStatusLbl.backgroundColor = .clear
        self.statusIcon.isHidden = true
        self.statusIcon.tintColor = .white
    }
    
    func configureViews(withData data: XNUILogInfo) {
        
        urlPathLbl.text = data.title
        urlPathLbl.sizeToFit()
        updateHTTPStatus(data.state, statusCode: data.statusCode)
        httpMethodLbl.text = data.httpMethod
        
        if let startDate = data.startTime {
            requestStartTimeLbl.text = dateFormatter.string(from: startDate)
        }
        else {
            requestStartTimeLbl.text = ""
        }
        requestDurationLbl.text = data.durationStr
        self.selectionStyle = UITableViewCell.SelectionStyle.none
    }
    
    private func updateHTTPStatus(_ status: XNSessionState?, statusCode: Int?) {
        
        func updateStatusLabel(color: UIColor, message: String?, icon: UIImage? = nil) {
            self.statusView.backgroundColor = color
            
            if let msg = message {
                self.httpStatusLbl.text = msg
                self.httpStatusLbl.isHidden = false
                self.statusIcon.isHidden = true
            }
            else if let iconImg = icon {
                self.statusIcon.image = iconImg
                self.statusIcon.isHidden = false
                self.httpStatusLbl.isHidden = true
            } else{
                self.httpStatusLbl.text = nil
                self.statusIcon.image = nil
                self.statusIcon.isHidden = true
                self.httpStatusLbl.isHidden = true
            }
        }
        
        func updateStatusFromResponse() {
            if let statusCode = statusCode {
                if 100...199 ~= statusCode {
                    updateStatusLabel(color: XNUIHTTPStatusColor.status1xx, message: "\(statusCode)")
                } else if 200...299 ~= statusCode {
                    updateStatusLabel(color: XNUIHTTPStatusColor.status2xx, message: "\(statusCode)")
                } else if 300...399 ~= statusCode {
                    updateStatusLabel(color: XNUIHTTPStatusColor.status3xx, message: "\(statusCode)")
                } else if 400...499 ~= statusCode {
                    updateStatusLabel(color: XNUIHTTPStatusColor.status4xx, message: "\(statusCode)")
                } else if 500...599 ~= statusCode {
                    updateStatusLabel(color: XNUIHTTPStatusColor.status5xx, message: "\(statusCode)")
                } else {
                    updateStatusLabel(color: XNUIHTTPStatusColor.unknown, message: "\(statusCode)")
                }
            } else {
                let icon = UIImage(named: "information", in: Bundle.current(), compatibleWith: nil)
                updateStatusLabel(color: XNUIHTTPStatusColor.unknown, message: nil, icon: icon)
            }
        }
        
        if statusCode != nil {
            updateStatusFromResponse()
            return
        }
        
        guard let reqtStatus = status
        else {
            let icon = UIImage(named: "information", in: Bundle.current(), compatibleWith: nil)
            updateStatusLabel(color: XNUIHTTPStatusColor.unknown, message: nil, icon: icon)
            return
        }
        
        switch reqtStatus {
        case .running:
            let icon = UIImage(named: "wait", in: Bundle.current(), compatibleWith: nil)
            updateStatusLabel(color: XNUIHTTPStatusColor.running, message: nil, icon: icon)
        case .canceling:
            let icon = UIImage(named: "cancel", in: Bundle.current(), compatibleWith: nil)
            updateStatusLabel(color: XNUIHTTPStatusColor.cancelled, message: nil, icon: icon)
        case .suspended:
            let icon = UIImage(named: "pause", in: Bundle.current(), compatibleWith: nil)
            updateStatusLabel(color: XNUIHTTPStatusColor.suspended, message: nil, icon: icon)
        case .unknown:
            let icon = UIImage(named: "information", in: Bundle.current(), compatibleWith: nil)
            updateStatusLabel(color: XNUIHTTPStatusColor.unknown, message: nil, icon: icon)
        case .completed:
            updateStatusFromResponse()
        }
        
    }
}
