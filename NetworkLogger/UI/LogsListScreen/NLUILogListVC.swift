//
//  NLLogListViewController.swift
//  XNLogger
//
//  Created by Sunil Sharma on 16/08/19.
//  Copyright © 2019 Sunil Sharma. All rights reserved.
//

import UIKit

class NLUILogListVC: NLUIBaseViewController {

    @IBOutlet weak var logListTableView: UITableView!
    private var logsDataDict: [String: XNLogData] = [:]
    private var logsIdArray: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViews()
        self.tabBarController?.tabBar.isHidden = true
        self.hidesBottomBarWhenPushed = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadLogData), name: NLUIConstants.logDataUpdtNotificationName, object: nil)
        reloadLogData()
    }
    
    func configureViews() {
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissNetworkUI))
        self.navigationItem.rightBarButtonItems = [doneButton]
        navigationController?.navigationBar.barTintColor = .white
        tabBarController?.tabBar.barTintColor = .white
        self.navigationController?.view.backgroundColor = .white
        
        self.logListTableView.tableFooterView = UIView()
        self.logListTableView.register(ofType: NLUILogListTableViewCell.self)
        self.logListTableView.dataSource = self
        self.logListTableView.delegate = self
        
    }
    
    @objc func dismissNetworkUI() {
        NLUIManager.shared.dismissNetworkUI()
    }
    
    func getLogData(indexPath: IndexPath) -> XNLogData? {
        return self.logsDataDict[logsIdArray[logsIdArray.count - 1 - indexPath.row]]
    }
    
    @objc func reloadLogData() {
        DispatchQueue.main.async {
            self.logsDataDict = NLUIManager.shared.logsDataDict
            self.logsIdArray = NLUIManager.shared.logsIdArray
            self.logListTableView.reloadData()
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: NLUIConstants.logDataUpdtNotificationName, object: nil)
    }
}

extension NLUILogListVC: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return logsIdArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: NLUILogListTableViewCell = tableView.dequeueReusableCell(for: indexPath)
        if let logData = getLogData(indexPath: indexPath) {
            cell.configureViews(withData: logData)
        }
        
        return cell
    }
}

extension NLUILogListVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let logData = getLogData(indexPath: indexPath),
            let detailController = NLUILogDetailVC.instance() {
            detailController.logData = logData
            self.navigationController?.pushViewController(detailController, animated: true)
        }
    }
}

