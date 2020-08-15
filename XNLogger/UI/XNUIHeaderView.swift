//
//  XNUIHeaderView.swift
//  XNLogger
//
//  Created by Sunil Sharma on 07/07/20.
//  Copyright © 2020 Sunil Sharma. All rights reserved.
//

import UIKit

class XNUIHeaderView: UIView {
    
    let leftBarView: UIStackView = UIStackView()
    let rightBarView: UIStackView = UIStackView()
    private let safeAreaView: UIView = UIView()
    private var safeAreaHeightContraint: NSLayoutConstraint?
    private var headerViewHeightConstraint: NSLayoutConstraint?
    
    var titleView: UIView = UIView() {
        didSet {
            oldValue.removeFromSuperview()
            setupTitleView()
        }
    }
    var titleLabel: UILabel?
    var ignoreStatusBarHeight: Bool {
        return XNUIManager.shared.isMiniModeActive
    }
    var headerHeight: CGFloat {
        return 43
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateHeaderHeight()
    }
    
    private func setupView() {
        
        func configureStackView(stackView: UIStackView) {
            
            stackView.axis = .horizontal
            stackView.spacing = 5
            stackView.translatesAutoresizingMaskIntoConstraints = false
            stackView.removeFromSuperview()
            self.addSubview(stackView)
        }
        
        self.translatesAutoresizingMaskIntoConstraints = false
        
        // Clear all constraints
        for constraint in self.constraints {
            self.removeConstraint(constraint)
        }
        self.headerViewHeightConstraint = self.heightAnchor.constraint(equalToConstant: 0)
        headerViewHeightConstraint?.isActive = true
        
        self.addSubview(safeAreaView)
        self.safeAreaView.translatesAutoresizingMaskIntoConstraints = false
        self.safeAreaView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0).isActive = true
        self.safeAreaView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0).isActive = true
        self.safeAreaView.topAnchor.constraint(equalTo: self.topAnchor, constant: 0).isActive = true
        self.safeAreaHeightContraint = self.safeAreaView.heightAnchor.constraint(equalToConstant: 0)
        safeAreaHeightContraint?.priority = UILayoutPriority(999)
        safeAreaHeightContraint?.isActive = true
        
        configureStackView(stackView: leftBarView)
        configureStackView(stackView: rightBarView)
        
        // Left bar constraints
        leftBarView.topAnchor.constraint(equalTo: self.safeAreaView.bottomAnchor, constant: 0).isActive = true
        leftBarView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0).isActive = true
        leftBarView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 9).isActive = true
        
        // Right bar constraints
        rightBarView.topAnchor.constraint(equalTo: self.safeAreaView.bottomAnchor, constant: 0).isActive = true
        rightBarView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0).isActive = true
        rightBarView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -9).isActive = true
        
        setupTitleView()
        addTitleLabel()
        self.layoutIfNeeded()
        
        titleView.backgroundColor = .clear
        self.safeAreaView.backgroundColor = .clear
        
    }
    
    func statusBarHeight() -> CGFloat {
        var height: CGFloat = 0
        if ignoreStatusBarHeight {
            return height
        }
        if #available(iOS 13.0, *) {
            height = UIApplication.shared.keyWindow?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
        } else {
            height = UIApplication.shared.statusBarFrame.height
        }
        return height
    }
    
    func updateHeaderHeight() {
        self.headerViewHeightConstraint?.constant = headerHeight + statusBarHeight()
        self.safeAreaHeightContraint?.constant = statusBarHeight()
        self.layoutIfNeeded()
    }
    
    func setupTitleView() {
        titleView.removeFromSuperview()
        self.addSubview(self.titleView)
        titleView.translatesAutoresizingMaskIntoConstraints = false
        
        titleView.topAnchor.constraint(equalTo: self.safeAreaView.bottomAnchor, constant: 0).isActive = true
        titleView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0).isActive = true
        titleView.leadingAnchor.constraint(equalTo: self.leftBarView.trailingAnchor, constant: 0).isActive = true
        titleView.trailingAnchor.constraint(equalTo: self.rightBarView.leadingAnchor, constant: 0).isActive = true
    }
    
    func addTitleLabel() {
        if self.titleLabel != nil {
            self.titleLabel?.removeFromSuperview()
            self.titleLabel = nil
        }
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = .clear
        
        self.titleLabel = label
        self.titleView.addSubview(label)
        self.titleLabel?.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        self.titleLabel?.centerYAnchor.constraint(equalTo: self.titleView.centerYAnchor).isActive = true
        
    }
    
    func setTitle(_ title: String, attributes: [NSAttributedString.Key: Any] = [.foregroundColor: XNUIAppColor.navTint, .font: UIFont.systemFont(ofSize: 20, weight: .semibold)]) {
        addTitleLabel()
        self.titleLabel?.attributedText = NSAttributedString(string: title, attributes: attributes)
    }
    
    func addBackButton(target: Any?, selector: Selector) {
        let backButton = XNUIHelper().createNavButton(imageName: "back", imageInsets: UIEdgeInsets(top: 11, left: 0, bottom: 11, right: 24))
        backButton.addTarget(target, action: selector, for: .touchUpInside)
        addBarButtonConstraints(backButton)
        leftBarView.insertArrangedSubview(backButton, at: 0)
    }
    
    func addleftBarItems(_ items: [UIView]) {
        // Clear previous items
        leftBarView.arrangedSubviews.forEach { (subView) in
            subView.removeFromSuperview()
        }
        
        items.forEach { (item) in
            addBarButtonConstraints(item)
            leftBarView.addArrangedSubview(item)
        }
    }
    
    func addRightBarItems(_ items: [UIView]) {
        // Clear previous items
        rightBarView.arrangedSubviews.forEach { (subView) in
            subView.removeFromSuperview()
        }
        
        items.forEach { (item) in
            addBarButtonConstraints(item)
            rightBarView.addArrangedSubview(item)
        }
    }
    
    private func addBarButtonConstraints(_ item: UIView) {
        item.translatesAutoresizingMaskIntoConstraints = false
        item.heightAnchor.constraint(equalToConstant: headerHeight).isActive = true
        item.widthAnchor.constraint(equalToConstant: headerHeight).isActive = true
    }
    
}
