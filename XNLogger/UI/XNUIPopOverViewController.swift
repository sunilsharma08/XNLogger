//
//  XNUIPopOverViewController.swift
//  XNLogger
//
//  Created by Sunil Sharma on 10/07/20.
//  Copyright © 2020 Sunil Sharma. All rights reserved.
//

import UIKit

protocol XNUIPopoverDelegate: AnyObject {
    func popover(_ popover: XNUIPopOverViewController, didSelectItem item: XNUIOptionItem, indexPath: IndexPath)
}

class XNUIPopOverViewController: UIViewController {

    let cellIdentifier = "defaultCellIdentifier"
    var maxPopoverSize: CGSize = CGSize(width: 200, height: 300)
    let itemsTableView: UITableView = UITableView()
    weak var delegate: XNUIPopoverDelegate?
    
    var items: [XNUIOptionItem] = [] {
        didSet {
            calculateAndSetPreferredContentSize()
            itemsTableView.reloadData()
        }
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        configurePopover()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configurePopover()
    }
    
    func configurePopover() {
        self.modalPresentationStyle = .popover
        popoverPresentationController?.delegate = self
        popoverPresentationController?.permittedArrowDirections = [.up]
        popoverPresentationController?.popoverLayoutMargins = .zero
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViews()
        calculateAndSetPreferredContentSize()
    }

    func configureViews() {
        
        let helper = XNUIHelper()
        if let window = helper.getWindow() {
            let maxPopoverWidth = window.bounds.width * 0.7
            let maxPopoverHeight = window.bounds.height * 0.7
            maxPopoverSize = CGSize(width: maxPopoverWidth, height: maxPopoverHeight)
        }
        self.view.addSubview(itemsTableView)
        self.automaticallyAdjustsScrollViewInsets = false
        
        itemsTableView.clipsToBounds = true
        itemsTableView.translatesAutoresizingMaskIntoConstraints = false
        itemsTableView.showsVerticalScrollIndicator = false
        itemsTableView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0).isActive = true
        itemsTableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        itemsTableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        itemsTableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        
        itemsTableView.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        itemsTableView.delegate = self
        itemsTableView.dataSource = self
        
        self.view.backgroundColor = .clear
        self.itemsTableView.backgroundColor = .clear
    }
    
    func calculateAndSetPreferredContentSize() {
        let labelPadding: CGFloat = 36
        var popoverWidth: CGFloat = 150 // Min popover width
        var popoverHeight: CGFloat = 0
        
        for item in items {
            let itemSize = item.title.heightWithConstrainedWidth(maxPopoverSize.width - labelPadding, font: item.font)
            popoverHeight += max(ceil(itemSize.height), 23)
            popoverHeight += 21 // Vertical padding
            popoverWidth = max(ceil(itemSize.width), popoverWidth)
        }
        
        popoverWidth = min(popoverWidth + labelPadding, maxPopoverSize.width)
        popoverHeight = min(popoverHeight, maxPopoverSize.height)
        preferredContentSize = CGSize(width: popoverWidth, height: popoverHeight)
    }
    
}

extension XNUIPopOverViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        let item = items[indexPath.row]
        cell.textLabel?.text = item.title
        cell.textLabel?.font = item.font
        if item.isSelected {
            cell.textLabel?.textColor = XNUIAppColor.primary
        } else {
            cell.textLabel?.textColor = .systemBlue
        }
        
        cell.textLabel?.numberOfLines = 0
        cell.backgroundColor = .clear
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        DispatchQueue.main.safeAsync {[weak self] in
            guard let self = self else { return }
            let item = self.items[indexPath.row]
            for (index, _) in self.items.enumerated() {
                self.items[index].isSelected = index == indexPath.row
            }
            tableView.reloadData()
            self.delegate?.popover(self, didSelectItem: item, indexPath: indexPath)
        }
    }
}

extension XNUIPopOverViewController: UIPopoverPresentationControllerDelegate {
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}
