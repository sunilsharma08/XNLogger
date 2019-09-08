//
//  NLUILogDetailView.swift
//  NetworkLogger
//
//  Created by Sunil Sharma on 29/08/19.
//  Copyright © 2019 Sunil Sharma. All rights reserved.
//

import UIKit

class NLUILogDetailView: UIView, NibLoadableView {

    @IBOutlet weak var logDetailsTableView: UITableView!
    var detailsArray: [NLUILogDetail] = []
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
        let nib = UINib(nibName: NLUILogDetailView.className, bundle: Bundle.current())
        guard let xibView = nib.instantiate(withOwner: self, options: nil).first as? UIView
        else {
            fatalError("Failed to load xib file \(NLUILogDetailView.nibName)")
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
        
        self.logDetailsTableView.registerForHeaderFooterView(ofType: NLUILogDetailHeaderCell.self)
        self.logDetailsTableView.register(ofType: NLUILogDetailCell.self)
        self.logDetailsTableView.dataSource = self
        self.logDetailsTableView.delegate = self
    }
    
    func upadteView(with logDetails: [NLUILogDetail]) {
        self.detailsArray = logDetails
        self.logDetailsTableView.reloadData()
    }
}

extension NLUILogDetailView: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return detailsArray.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return detailsArray[section].messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: NLUILogDetailCell = tableView.dequeueReusableCell(for: indexPath)
        cell.logDetailMsg.text = self.detailsArray[indexPath.section].messages[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let headerView: NLUILogDetailHeaderCell = tableView.dequeueReusableHeaderFooterView(withIdentifier: NLUILogDetailHeaderCell.defaultReuseIdentifier) as? NLUILogDetailHeaderCell
        else { return UIView() }
        let logData: NLUILogDetail = self.detailsArray[section]
        headerView.titleLbl.text = logData.title
        return headerView
    }
    
}

extension NLUILogDetailView: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}
