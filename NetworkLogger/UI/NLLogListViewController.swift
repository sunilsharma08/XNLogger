//
//  NLLogListViewController.swift
//  NetworkLogger
//
//  Created by Sunil Sharma on 16/08/19.
//  Copyright © 2019 Sunil Sharma. All rights reserved.
//

import UIKit

protocol NLUILogListDelegate: class {
    func receivedLogData(_ logData: NLLogData, isResponse: Bool)
}

class NLLogListViewController: NLUIBaseViewController {

    @IBOutlet weak var logListTableView: UITableView!
    private var logsDataDict: [String: NLLogData] = [:]
    private var logsIdArray: [String] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViews()
        logsDataDict = NLUIManager.shared.logsDataDict
        logsIdArray = NLUIManager.shared.logsIdArray
    }
    
    func configureViews() {
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissNetworkUI))
        self.navigationItem.rightBarButtonItems = [doneButton]
        
        self.logListTableView.tableFooterView = UIView()
        self.logListTableView.register(ofType: NLUILogListTableViewCell.self)
        self.logListTableView.dataSource = self
        
    }
    
    @objc func dismissNetworkUI() {
        NLUIManager.shared.dismissNetworkUI()
    }

}

extension NLLogListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return logsIdArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: NLUILogListTableViewCell = tableView.dequeueReusableCell(for: indexPath)
        if let logData = self.logsDataDict[logsIdArray[logsIdArray.count - 1 - indexPath.row]] {
            cell.configureViews(withData: logData)
        }
        
        return cell
    }
    
}



