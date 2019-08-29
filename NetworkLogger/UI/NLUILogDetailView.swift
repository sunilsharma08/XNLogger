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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configureViews()
    }
    
    func configureViews() {
        self.logDetailsTableView.tableFooterView = UIView()
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
        return cell
    }
    
}

extension NLUILogDetailView: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}
