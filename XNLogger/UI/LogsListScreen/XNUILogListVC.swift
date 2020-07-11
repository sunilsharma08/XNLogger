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
    @IBOutlet weak var emptyMsgLabel: UILabel!
    
    private var logsDataDict: [String: XNUILogInfo] {
        return XNUIManager.shared.getLogsDataDict()
    }
    
    private var logsIdArray: [String] {
        return XNUIManager.shared.getLogsIdArray()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureViews()
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateLoggerUI), name: .logDataUpdate, object: nil)
        updateLoggerUI()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.headerView?.setTitle("XNLogger", attributes: [.foregroundColor: XNUIAppColor.navTint, .font: UIFont.systemFont(ofSize: 24, weight: .semibold)])
    }
    
    func configureViews() {
        let closeButton = helper.createNavButton(
                        imageName: "close",
                        imageInsets: UIEdgeInsets(top: 18, left: 27, bottom: 10, right: 5))
        closeButton.addTarget(self, action: #selector(dismissNetworkUI), for: .touchUpInside)
        let clearLogsButton = helper.createNavButton(
                            imageName: "trash",
                            imageInsets: UIEdgeInsets(top: 10, left: 2, bottom: 10, right: 21))
        clearLogsButton.addTarget(self, action: #selector(clearLogs), for: .touchUpInside)
        
        self.headerView?.addRightBarItems([closeButton])
        self.headerView?.addleftBarItems([clearLogsButton])
        
        self.logListTableView.tableFooterView = UIView()
        self.logListTableView.register(ofType: XNUILogListTableViewCell.self)
        self.logListTableView.dataSource = self
        self.logListTableView.delegate = self
        self.emptyMsgLabel.text = "No network logs found!"
        
    }
    
    @objc func dismissNetworkUI() {
        XNUIManager.shared.dismissNetworkUI()
    }
    
    @objc func clearLogs() {
        XNUIManager.shared.clearLogs()
        updateLoggerUI()
    }
    
    /**
     Return index for `logsIdArray` w.r.t to UITableView rows.
     */
    func getLogIdArrayIndex(for indexPath: IndexPath) -> Int? {
        let logIds = self.logsIdArray
        if logIds.count > indexPath.row {
            return (logIds.count - 1) - indexPath.row
        }
        return nil
    }
    
    /**
     Return `XNLogData` for given index path.
     */
    func getLogData(indexPath: IndexPath) -> XNUILogInfo? {
        if let index = getLogIdArrayIndex(for: indexPath) {
            return logsDataDict[logsIdArray[index]]
        }
        return nil
    }
    
    @objc func updateLoggerUI() {
        DispatchQueue.main.async {
            self.logListTableView.reloadData()
            self.emptyMsgLabel.isHidden = !self.logsIdArray.isEmpty
            self.navigationItem.leftBarButtonItem?.customView?.isHidden = !self.emptyMsgLabel.isHidden
        }
    }
    
    deinit {
        print("\(type(of: self)) \(#function)")
        NotificationCenter.default.removeObserver(self, name: .logDataUpdate, object: nil)
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
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            if let index = getLogIdArrayIndex(for: indexPath) {
                XNUIManager.shared.removeLogAt(index: index)
                tableView.deleteRows(at: [indexPath], with: .automatic)
                if logsIdArray.isEmpty {
                    updateLoggerUI()
                }
            }
        }
    }
}

extension XNUILogListVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let logData = getLogData(indexPath: indexPath),
            let detailController = XNUILogDetailVC.instance() {
            detailController.logInfo = logData
            self.navigationController?.pushViewController(detailController, animated: true)
        }
    }
}

