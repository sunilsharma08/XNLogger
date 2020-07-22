//
//  XNUISettingsCell.swift
//  XNLogger
//
//  Created by Sunil Sharma on 22/07/20.
//  Copyright © 2020 Sunil Sharma. All rights reserved.
//

import UIKit

protocol XNUISettingsCellDelegate: AnyObject {
    func switchValueChanged(_ isOn: Bool, settingItem: XNUISettingItem)
}

class XNUISettingsCell: UITableViewCell {

    @IBOutlet weak var settingTitleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var settingSwitch: UISwitch!
    @IBOutlet weak var accessoryViewWidth: NSLayoutConstraint!
    @IBOutlet weak var rightAccessoryView: UIView!
    
    var cellData: XNUISettingItem? = nil
    weak var delegate: XNUISettingsCellDelegate?
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        updateSelectionColor(isSelected: selected)
        
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        updateSelectionColor(isSelected: highlighted)
    }
    
    func updateSelectionColor(isSelected: Bool) {
        guard cellData?.type == XNUISettingType.clearData
            else { return }
        
        if isSelected {
            contentView.backgroundColor = UIColor(red: 229/255.0, green: 229/255.0, blue: 234/255.0, alpha: 1)
        } else {
            contentView.backgroundColor = UIColor.white
        }
    }
    
    func updateCell(with settingItem: XNUISettingItem) {
        self.cellData = settingItem
        
        settingTitleLabel.text = settingItem.title
        subTitleLabel.isHidden = settingItem.subTitle == nil
        subTitleLabel.text = settingItem.subTitle
        
        settingTitleLabel.textColor = settingItem.textColor
                
        if let data = settingItem.value as? Bool {
            settingSwitch.isOn = data
            accessoryViewWidth.constant = 55
            rightAccessoryView.isHidden = false
        } else {
            accessoryViewWidth.constant = 0
            rightAccessoryView.isHidden = true
        }
    }
    
    @IBAction func switchValueChanged(_ sender: Any) {
        guard let settingSwitch = sender as? UISwitch,
            let settingItem = self.cellData
            else { return }
        settingItem.value = settingSwitch.isOn
        delegate?.switchValueChanged(settingSwitch.isOn, settingItem: settingItem)
    }
}
