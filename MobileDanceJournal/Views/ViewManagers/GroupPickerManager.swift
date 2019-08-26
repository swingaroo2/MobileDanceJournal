//
//  GroupPickerManager.swift
//  MobileDanceJournal
//
//  Created by Zach Lockett-Streiff on 8/24/19.
//  Copyright © 2019 Swingaroo2. All rights reserved.
//

import Foundation
import UIKit

class GroupPickerManager: NSObject, PickerManager {
    var managedView: ToolbarPickerView
    var coreDataManager: CoreDataManager
    var oldGroup: Group?
    var newGroups: [Group]!
    var practiceLogToMove: PracticeSession!
    
    required init(_ managedView: ToolbarPickerView, _ coreDataManager: CoreDataManager) {
        self.managedView = managedView
        self.coreDataManager = coreDataManager
    }
    
}

extension GroupPickerManager {
    func doneButtonPressed() {
        let selectedRow = managedView.picker.selectedRow(inComponent: 0)
        let newGroup = selectedRow >= newGroups.count ? nil : newGroups[selectedRow]
        
        coreDataManager.move([practiceLogToMove], from: oldGroup, to: newGroup)
        managedView.hide()
    }
}

// MARK: UIPickerViewDelegate
extension GroupPickerManager {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let groupName = row >= newGroups.count ? TextConstants.uncategorized : newGroups[row].name
        return groupName
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        var label: UILabel
        
        if let view = view as? UILabel {
            label = view
        } else {
            label = UILabel()
        }
        
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont(name: "Menlo-Regular", size: 17)
        
        let groupName = row >= newGroups.count ? TextConstants.uncategorized : newGroups[row].name
        label.text = groupName
        
        return label
    }
}

// MARK: UIPickerViewDataSource
extension GroupPickerManager {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        // +1 for Uncategorized
        let count = oldGroup == nil ? newGroups.count : newGroups.count + 1
        return count
    }
}
