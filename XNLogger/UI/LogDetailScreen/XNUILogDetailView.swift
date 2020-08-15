//
//  XNUILogDetailView.swift
//  XNLogger
//
//  Created by Sunil Sharma on 29/08/19.
//  Copyright © 2019 Sunil Sharma. All rights reserved.
//

import UIKit

protocol XNUIDetailViewDelegate: class {
    func showMessageFullScreen(logData: XNUIMessageData, title: String)
}

class XNUILogDetailView: UIView, NibLoadableView {

    @IBOutlet weak var logDetailsTableView: UITableView!
    @IBOutlet weak var contentView: UIView!
    
    weak var delegate: XNUIDetailViewDelegate?
    
    var viewType: XNUIDetailViewType!
    var detailsArray: [XNUILogDetail] = []
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
        configureViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
        configureViews()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        configureViews()
    }
    
    func setupView() {
        let nib = UINib(nibName: XNUILogDetailView.className, bundle: Bundle.current())
        guard let xibView = nib.instantiate(withOwner: self, options: nil).first as? UIView
        else {
            fatalError("Failed to load xib file \(XNUILogDetailView.nibName)")
        }
        contentView = xibView
        self.contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        contentView.translatesAutoresizingMaskIntoConstraints = true
        addSubview(contentView)
    }
    
    func configureViews() {
        self.logDetailsTableView.tableFooterView = UIView()
        #if swift(>=4.2)
        self.logDetailsTableView.sectionHeaderHeight = UITableView.automaticDimension
        #else
            self.logDetailsTableView.sectionHeaderHeight = UITableViewAutomaticDimension
        #endif
        
        self.logDetailsTableView.estimatedSectionHeaderHeight = 45
        
        self.logDetailsTableView.registerForHeaderFooterView(ofType: XNUILogDetailHeaderCell.self)
        self.logDetailsTableView.register(ofType: XNUILogDetailCell.self)
        self.logDetailsTableView.dataSource = self
        self.logDetailsTableView.delegate = self
    }
    
    func upadteView(with logDetails: [XNUILogDetail]) {
        self.detailsArray = logDetails
        self.logDetailsTableView.reloadData()
    }
}

extension XNUILogDetailView: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return detailsArray.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if detailsArray.isEmpty {
            return 0
        } else {
            return detailsArray[section].messages.count
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let msgData = self.detailsArray[indexPath.section].messages[indexPath.row]
        
        if msgData.showOnlyInFullScreen == false {
            if msgData.msgCount > XNUIConstants.msgCellMaxCharCount {
                return UIScreen.main.bounds.height * 0.6
            }
            else if Int(msgData.message.heightWithConstrainedWidth(tableView.frame.width - 20, font: XNUIConstants.messageFont).height) > XNUIConstants.msgCellMaxLength {
                return UIScreen.main.bounds.height * 0.6
            }
        }
        
        #if swift(>=4.2)
        return UITableView.automaticDimension
        #else
        return UITableViewAutomaticDimension
        #endif
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: XNUILogDetailCell = tableView.dequeueReusableCell(for: indexPath)
        cell.configureViews(self.detailsArray[indexPath.section].messages[indexPath.row], indexPath: indexPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let headerView: XNUILogDetailHeaderCell = tableView.dequeueReusableHeaderFooterView(withIdentifier: XNUILogDetailHeaderCell.defaultReuseIdentifier) as? XNUILogDetailHeaderCell
        else { return UIView() }
        let logData: XNUILogDetail = self.detailsArray[section]
        headerView.titleLbl.text = logData.title
        return headerView
    }
    
}

extension XNUILogDetailView: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let msgData = self.detailsArray[indexPath.section].messages[indexPath.row]
        if msgData.showOnlyInFullScreen {
            delegate?.showMessageFullScreen(logData: msgData, title: self.detailsArray[indexPath.section].title)
        }
    }
}
