//
//  NLLogListVC.swift
//  XNLogger
//
//  Created by Sunil Sharma on 16/08/19.
//  Copyright © 2019 Sunil Sharma. All rights reserved.
//

import UIKit

class XNUILogListVC: XNUIBaseViewController {

    @IBOutlet weak var logListTableView: UITableView!
    private var logsDataDict: [String: XNLogData] = [:]
    private var logsIdArray: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViews()
        self.tabBarController?.tabBar.isHidden = true
        self.hidesBottomBarWhenPushed = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadLogData), name: XNUIConstants.logDataUpdtNotificationName, object: nil)
        reloadLogData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: XNUIAppColor.navLogo, .font: UIFont.systemFont(ofSize: 24, weight: .semibold)]
    }
    
    func configureViews() {
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissNetworkUI))
        self.navigationItem.rightBarButtonItems = [doneButton]
        
        
        self.tabBarController?.tabBar.barTintColor = .white
        
        self.logListTableView.tableFooterView = UIView()
        self.logListTableView.register(ofType: XNUILogListTableViewCell.self)
        self.logListTableView.dataSource = self
        self.logListTableView.delegate = self
        
    }
    
    @objc func dismissNetworkUI() {
        XNUIManager.shared.dismissNetworkUI()
    }
    
    func getLogData(indexPath: IndexPath) -> XNLogData? {
        return self.logsDataDict[logsIdArray[logsIdArray.count - 1 - indexPath.row]]
    }
    
    @objc func reloadLogData() {
        DispatchQueue.main.async {
            self.logsDataDict = XNUIManager.shared.logsDataDict
            self.logsIdArray = XNUIManager.shared.logsIdArray
            self.logListTableView.reloadData()
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: XNUIConstants.logDataUpdtNotificationName, object: nil)
    }
}

extension XNUILogListVC: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return logsIdArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: XNUILogListTableViewCell = tableView.dequeueReusableCell(for: indexPath)
        if let logData = getLogData(indexPath: indexPath) {
            cell.configureViews(withData: logData)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 71
    }
}

extension XNUILogListVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let logData = getLogData(indexPath: indexPath),
            let detailController = XNUILogDetailVC.instance() {
            detailController.logData = logData
            self.navigationController?.pushViewController(detailController, animated: true)
        }
    }
}

