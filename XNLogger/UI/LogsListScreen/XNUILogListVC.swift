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
        self.navigationItem.rightBarButtonItem = createNavButton(imageName: "close", action: #selector(dismissNetworkUI), imageInsets: UIEdgeInsets(top: 16, left: 28, bottom: 15, right: 2))
        self.navigationItem.leftBarButtonItem = createNavButton(imageName: "trash", action: #selector(clearLogs), imageInsets: UIEdgeInsets(top: 10, left: 0, bottom: 14, right: 24))
        self.navigationController?.navigationBar.layoutIfNeeded()
        self.tabBarController?.tabBar.barTintColor = .white
        
        self.logListTableView.tableFooterView = UIView()
        self.logListTableView.register(ofType: XNUILogListTableViewCell.self)
        self.logListTableView.dataSource = self
        self.logListTableView.delegate = self
        
    }
    
    func createNavButton(imageName: String, action: Selector, imageInsets: UIEdgeInsets) -> UIBarButtonItem {
        let customView = UIView(frame: CGRect(x: 0, y: 0, width: 45, height: 45))
        customView.backgroundColor = UIColor.clear
        let customButton = UIButton(frame: CGRect(x: 0, y: 0, width: customView.frame.width, height: customView.frame.height))
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
        reloadLogData()
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

