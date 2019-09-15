//
//  XNUILogDetailView.swift
//  XNLogger
//
//  Created by Sunil Sharma on 29/08/19.
//  Copyright © 2019 Sunil Sharma. All rights reserved.
//

import UIKit

class XNUILogDetailView: UIView, NibLoadableView {

    @IBOutlet weak var logDetailsTableView: UITableView!
    var detailsArray: [XNUILogDetail] = []
    @IBOutlet weak var contentView: UIView!
    
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
        self.logDetailsTableView.sectionHeaderHeight = UITableViewAutomaticDimension
        self.logDetailsTableView.estimatedSectionHeaderHeight = 45;
        self.logDetailsTableView.rowHeight = UITableViewAutomaticDimension
        
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
        
        return detailsArray[section].messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: XNUILogDetailCell = tableView.dequeueReusableCell(for: indexPath)
        cell.logDetailMsg.text = self.detailsArray[indexPath.section].messages[indexPath.row]
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
        
    }
}
