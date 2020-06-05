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
        self.tabBarController?.tabBar.isHidden = true
        self.hidesBottomBarWhenPushed = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateLoggerUI), name: XNUIConstants.logDataUpdtNotificationName, object: nil)
        updateLoggerUI()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: XNUIAppColor.navLogo, .font: UIFont.systemFont(ofSize: 24, weight: .semibold)]
    }
    
    func configureViews() {
        self.navigationItem.rightBarButtonItem = createNavButton(
            imageName: "close",
            action: #selector(dismissNetworkUI),
            imageInsets: UIEdgeInsets(top: 28, left: 32, bottom: 18, right: 2),
            buttonFrame: CGRect(x:-7, y: -10, width: 60, height: 60))
        
        self.navigationItem.leftBarButtonItem = createNavButton(
            imageName: "trash",
            action: #selector(clearLogs),
            imageInsets: UIEdgeInsets(top: 10, left: 0, bottom: 14, right: 24),
            buttonFrame: CGRect(x: 0, y: 0, width: 45, height: 45))
        self.navigationController?.navigationBar.layoutIfNeeded()
        self.tabBarController?.tabBar.barTintColor = .white
        
        self.logListTableView.tableFooterView = UIView()
        self.logListTableView.register(ofType: XNUILogListTableViewCell.self)
        self.logListTableView.dataSource = self
        self.logListTableView.delegate = self
        self.emptyMsgLabel.text = "No network logs found!"
        
    }
    
    func createNavButton(imageName: String, action: Selector, imageInsets: UIEdgeInsets, buttonFrame: CGRect) -> UIBarButtonItem {
        let customView = UIView(frame: CGRect(x: 0, y: 0, width: 45, height: 45))
        customView.backgroundColor = UIColor.clear
        let customButton = UIButton(frame: buttonFrame)
        customButton.tintColor = UIColor(red: 239/255.0, green: 239/255.0, blue: 239/255.0, alpha: 1)
        customButton.imageView?.contentMode = .scaleAspectFit
        customButton.imageEdgeInsets = imageInsets
        customButton.setImage(UIImage(named: imageName, in: Bundle.current(), compatibleWith: nil), for: .normal)
        customButton.addTarget(self, action: action, for: .touchUpInside)
        
        customView.addSubview(customButton)
        
        return UIBarButtonItem(customView: customView)
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

