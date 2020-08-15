//
//  XNUISettingsVC.swift
//  XNLogger
//
//  Created by Sunil Sharma on 16/08/19.
//  Copyright © 2019 Sunil Sharma. All rights reserved.
//

import UIKit

class XNUISettingsVC: XNUIBaseViewController {

    @IBOutlet weak var settingsTableView: UITableView!
    var settingCategory: [XNUISettingCategory] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViews()
        loadData()
        settingsTableView.reloadData()
    }
    
    func configureViews() {
        self.headerView?.setTitle("Settings")
        self.edgesForExtendedLayout = []
        
        let closeButton = helper.createNavButton(
                        imageName: "close",
                        imageInsets: UIEdgeInsets(top: 15, left: 25, bottom: 9, right: 5))
        closeButton.addTarget(self, action: #selector(dismissNetworkUI), for: .touchUpInside)
        self.headerView?.addRightBarItems([closeButton])
        
        settingsTableView.register(ofType: XNUISettingsCell.self)
        settingsTableView.delegate = self
        settingsTableView.dataSource = self
    }
    
    func loadData() {
        let utility = XNUIHelper()
        let generalCategory = XNUISettingCategory()
        let startStop = XNUISettingItem(title: "Network Logging", type: .startStopLog)
        startStop.value = XNLogger.shared.isEnabled()
        generalCategory.items.append(startStop)
        
        let logSettings = XNUISettingCategory(title: " ")
        let textOnlyRequest = XNUISettingItem(title: "Log unreadable request body", subTitle: "Enable to log image, pdf, binary, etc.", type: .logUnreadableRequest, value: false)
        textOnlyRequest.value = XNUIManager.shared.uiLogHandler.logFormatter.logUnreadableReqstBody
        logSettings.items.append(textOnlyRequest)
        
        let textOnlyResponse = XNUISettingItem(title: "Log unreadable response", subTitle: "Enable to log image, pdf, binary, etc.", type: .logUnreadableResponse, value: false)
        textOnlyResponse.value = XNUIManager.shared.uiLogHandler.logFormatter.logUnreadableRespBody
        logSettings.items.append(textOnlyResponse)
    
        let clearActions = XNUISettingCategory(title: " ")
        let clearLog = XNUISettingItem(title: "Clear data", type: .clearData)
        clearLog.textColor = UIColor.systemRed
        clearActions.items.append(clearLog)
        
        let info = XNUISettingCategory(title: "About")
        let version = XNUISettingItem(title: "Version - \(utility.getVersion())", type: .version)
        version.textColor = UIColor.darkGray
        info.items.append(version)
        let help = XNUISettingItem(title: "Help", type: .help)
        if #available(iOS 13.0, *) {
            help.textColor = UIColor.link
        } else {
            help.textColor = UIColor.systemBlue
        }
        info.items.append(help)
        
        var categories: [XNUISettingCategory] = []
        categories.append(generalCategory)
        categories.append(logSettings)
        categories.append(clearActions)
        categories.append(info)
        
        self.settingCategory = categories
    }
    
    func updateLog(isEnabled: Bool) {
        if isEnabled {
            XNLogger.shared.startLogging()
        } else {
            XNLogger.shared.stopLogging()
        }
    }
    
    func updateLogUnreadableRequest(isEnabled: Bool) {
        XNUIManager.shared.uiLogHandler.logFormatter.logUnreadableReqstBody = isEnabled
    }
    
    func updateLogUnreadableResponse(isEnabled: Bool) {
        XNUIManager.shared.uiLogHandler.logFormatter.logUnreadableRespBody = isEnabled
    }
    
    func clearLogData() {
        XNUIManager.shared.clearLogs()
        if let logNav = self.tabBarController?.viewControllers?.first as? UINavigationController,
            let logListVC = logNav.viewControllers.first as? XNUILogListVC {
            logNav.popToRootViewController(animated: false)
            logListVC.updateLoggerUI()
        }
    }
    
    @objc func dismissNetworkUI() {
        XNUIManager.shared.dismissUI()
    }

}

extension XNUISettingsVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return settingCategory.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settingCategory[section].items.count
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 3
        } else {
            return UITableView.automaticDimension
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let category = settingCategory[section]
        return category.title
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNonzeroMagnitude
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: XNUISettingsCell = tableView.dequeueReusableCell(for: indexPath)
        let settingItem = settingCategory[indexPath.section].items[indexPath.row]
        cell.delegate = self
        cell.updateCell(with: settingItem)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = settingCategory[indexPath.section].items[indexPath.row]
        
        if item.type == .clearData {
            clearLogData()
        }
        
        if item.type == .help, let helpUrl = URL(string: "https://github.com/sunilsharma08/XNLogger") {
            if UIApplication.shared.canOpenURL(helpUrl) {
                UIApplication.shared.openURL(helpUrl)
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(200)) {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
}

extension XNUISettingsVC: XNUISettingsCellDelegate {
    
    func switchValueChanged(_ isOn: Bool, settingItem: XNUISettingItem) {
        
        if settingItem.type == .startStopLog {
            updateLog(isEnabled: isOn)
        }
        
        if settingItem.type == .logUnreadableRequest {
            updateLogUnreadableRequest(isEnabled: isOn)
        }
        
        if settingItem.type == .logUnreadableResponse {
            updateLogUnreadableResponse(isEnabled: isOn)
        }
    }
}
