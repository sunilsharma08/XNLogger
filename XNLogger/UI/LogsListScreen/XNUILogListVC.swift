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
    @IBOutlet weak var searchContainerHeight: NSLayoutConstraint!
    @IBOutlet weak var searchContainerView: UIView!
    @IBOutlet weak var logSearchBar: UISearchBar!
    
    var isSearchActive: Bool = false
    let maxSearchBarHeight: CGFloat = 42;
    let minSearchBarHeight: CGFloat = 0;
    
    /// The last known scroll position
    var previousScrollOffset: CGFloat = 0
    
    /// The last known height of the scroll view content
    var previousScrollViewHeight: CGFloat = 0
    
    var viewModeBarButton: UIButton = UIButton()
    
    private var logsDataDict: [String: XNUILogInfo] {
        return XNUIManager.shared.getLogsDataDict()
    }
    
    private var logsIdArray: [String] {
        return XNUIManager.shared.getLogsIdArray()
    }
    
    private var searchResult: [XNUILogInfo] = []
    
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
            imageInsets: UIEdgeInsets(top: 15, left: 25, bottom: 9, right: 5))
        closeButton.addTarget(self, action: #selector(dismissNetworkUI), for: .touchUpInside)
        
        viewModeBarButton = helper.createNavButton(
            imageName: "minimise",
            imageInsets: UIEdgeInsets(top: 10, left: 6, bottom: 7, right: 12))
        viewModeBarButton.addTarget(self, action: #selector(upadteViewMode), for: .touchUpInside)
        
        self.headerView?.addRightBarItems([closeButton])
        self.headerView?.addleftBarItems([viewModeBarButton])
        
        self.logListTableView.tableFooterView = UIView()
        self.logListTableView.register(ofType: XNUILogListTableViewCell.self)
        self.logListTableView.dataSource = self
        self.logListTableView.delegate = self
        self.emptyMsgLabel.text = "No network logs found!"
        
        self.searchContainerHeight.constant = 0
        self.logSearchBar.delegate = self
    }
    
    @objc func dismissNetworkUI() {
        XNUIManager.shared.dismissNetworkUI()
    }
    
    @objc func upadteViewMode() {
        let enableMiniView = !XNUIManager.shared.isMiniModeActive
        updateViewModeIcon(isMiniViewEnabled: enableMiniView)
        XNUIManager.shared.updateViewMode(enableMiniView: enableMiniView)
    }
    
    func updateViewModeIcon(isMiniViewEnabled: Bool) {
        
        UIView.transition(with: self.viewModeBarButton, duration: 0.3, options: .transitionCrossDissolve, animations: {
            if isMiniViewEnabled {
                self.viewModeBarButton.setImage(UIImage(named: "maximise", in: Bundle.current(), compatibleWith: nil), for: .normal)
            } else {
                self.viewModeBarButton.setImage(UIImage(named: "minimise", in: Bundle.current(), compatibleWith: nil), for: .normal)
            }
        }, completion: nil)
        
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
        if isSearchActive && searchResult.count > indexPath.row {
            return searchResult[indexPath.row]
        }
        if let index = getLogIdArrayIndex(for: indexPath) {
            return logsDataDict[logsIdArray[index]]
        }
        return nil
    }
    
    @objc func updateLoggerUI() {
        DispatchQueue.main.async {
            self.logListTableView.reloadData()
            self.emptyMsgLabel.isHidden = !self.logsIdArray.isEmpty
        }
    }
    
    deinit {
        print("\(type(of: self)) \(#function)")
        NotificationCenter.default.removeObserver(self, name: .logDataUpdate, object: nil)
    }
}

extension XNUILogListVC: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearchActive {
            return searchResult.count
        }
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
        return 68
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
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return isSearchActive == false
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

extension XNUILogListVC: UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
        isSearchActive = true
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.text = nil
        searchBar.showsCancelButton = false
        isSearchActive = false
        updateLoggerUI()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar(searchBar, textDidChange: searchBar.text ?? "")
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        guard searchText.isEmpty == false
        else {
            isSearchActive = false
            searchResult.removeAll()
            logListTableView.reloadData()
            return
        }
        
        var results: [XNUILogInfo] = []
        let logIds = logsIdArray.reversed()
        for logId in logIds {
            if let logInfo = logsDataDict[logId], let title = logInfo.title?.lowercased() {
                if title.contains(searchText.lowercased()) {
                    results.append(logInfo)
                }
            }
        }
        isSearchActive = true
        searchResult = results
        logListTableView.reloadData()
        self.emptyMsgLabel.isHidden = !self.searchResult.isEmpty
    }
}

extension XNUILogListVC {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        defer {
            self.previousScrollViewHeight = scrollView.contentSize.height
            self.previousScrollOffset = scrollView.contentOffset.y
        }
        
        let scrollSizeDiff = scrollView.contentSize.height - self.previousScrollViewHeight
        // If the scroll was caused by the height of the scroll view changing, we want to do nothing.
        guard scrollSizeDiff == 0 else { return }
        
        let scrollDiff = scrollView.contentOffset.y - self.previousScrollOffset
        let absoluteTop: CGFloat = 0
        let absoluteBottom: CGFloat = max((scrollView.contentSize.height - scrollView.frame.size.height), scrollView.contentSize.height)
        
        let isScrollingDown = scrollDiff > 0 && scrollView.contentOffset.y > absoluteTop
        let isScrollingUp = scrollDiff < 0 && scrollView.contentOffset.y < absoluteBottom
        
        var newHeight = self.searchContainerHeight.constant
        // Display search bar when scroll view is at top
        if isScrollingUp && scrollView.contentOffset.y < 0 {
            newHeight = min(self.maxSearchBarHeight, self.searchContainerHeight.constant + abs(scrollDiff))
        }
        
        if isScrollingDown {
            newHeight = max(self.minSearchBarHeight, self.searchContainerHeight.constant - abs(scrollDiff))
        }
        
        if newHeight != self.searchContainerHeight.constant {
            updateSearchBar(height: newHeight, animated: false)
            self.setScrollPosition(self.previousScrollOffset)
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if decelerate == false {
            scrollViewDidStopScrolling()
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        scrollViewDidStopScrolling()
    }
    
    func scrollViewDidStopScrolling() {
        let range = self.maxSearchBarHeight - self.minSearchBarHeight
        let midPoint = self.minSearchBarHeight + (range * 0.6)
        
        if self.searchContainerHeight.constant > midPoint {
            updateSearchBar(height: self.maxSearchBarHeight, animated: true)
        } else {
            updateSearchBar(height: self.minSearchBarHeight, animated: true)
        }
    }
    
    func setScrollPosition(_ position: CGFloat) {
        self.logListTableView.contentOffset = CGPoint(x: self.logListTableView.contentOffset.x, y: position)
    }
    
    func updateSearchBar(height: CGFloat, animated: Bool) {
        if logsIdArray.isEmpty {
            self.searchContainerHeight.constant = self.minSearchBarHeight
            return
        }
        
        if isSearchActive {
            self.searchContainerHeight.constant = self.maxSearchBarHeight
            return
        }
        
        self.view.layoutIfNeeded()
        let animationDuration: TimeInterval = animated ? 0.2 : 0
        UIView.animate(withDuration: animationDuration, delay: 0, options: [.allowUserInteraction, .curveEaseInOut], animations: {
            self.searchContainerHeight.constant = height
            self.updateSearchBarUI()
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    func updateSearchBarUI() {
        let range = self.maxSearchBarHeight - self.minSearchBarHeight
        let openAmount = self.searchContainerHeight.constant - self.minSearchBarHeight
        let percentage = openAmount / range
        var searchTextField: UITextField?
        
        if #available(iOS 13.0, *) {
            searchTextField = self.logSearchBar.searchTextField
        } else {
            searchTextField = self.logSearchBar.value(forKey: "searchField") as? UITextField
        }
        
        if percentage < 0.6 {
            searchTextField?.alpha = 0
        } else {
            searchTextField?.alpha = percentage
        }
        self.logSearchBar.alpha = percentage
    }
}

