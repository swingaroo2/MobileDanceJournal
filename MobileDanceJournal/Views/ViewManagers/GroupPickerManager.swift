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
    var coordinator: PracticeLogCoordinator
    var oldGroup: Group?
    var newGroups: [Group]!
    var practiceLogToMove: PracticeSession!
    
    required init(_ managedView: ToolbarPickerView,_ coordinator: PracticeLogCoordinator) {
        Log.trace()
        self.managedView = managedView
        self.coordinator = coordinator
    }
}

extension GroupPickerManager {
    func doneButtonPressed() {
        Log.trace()
        let selectedRow = managedView.picker.selectedRow(inComponent: 0)
        
        guard let managedTableView = (coordinator.rootVC.masterVC as! PracticeLogVC).tableView else {
            Log.error("Failed to get reference to managed Table View. Hiding picker")
            managedView.hide()
            return
        }
        
        // Get Practice Logs in the old Group
        guard let practiceLogs = Model.coreData.fetchPracticeSessions(in: oldGroup) else {
            Log.error("Failed to get reference to Practice Logs. Hiding picker")
            managedView.hide()
            return
        }
        
        // Get rowIndex of IndexPath
        guard let rowIndex = practiceLogs.firstIndex(of: practiceLogToMove) else {
            Log.error("Failed to get reference to the index of the Practice Log to move. Hiding picker")
            managedView.hide()
            return
        }
        
        let indexPath = IndexPath(row: rowIndex, section: 0)
        let newGroup = selectedRow >= newGroups.count ? nil : newGroups[selectedRow]
        
        Model.coreData.move([practiceLogToMove], from: oldGroup, to: newGroup)
        managedTableView.deleteRows(at: [indexPath], with: .fade)
        NotificationCenter.default.post(name: .practiceLogMoved, object: self, userInfo: nil)
        managedView.hide()
    }
}

// MARK: UIPickerViewDelegate
extension GroupPickerManager {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        Log.trace()
        let groupName = row >= newGroups.count ? TextConstants.uncategorized : newGroups[row].name
        return groupName
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        Log.trace()
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
        Log.trace()
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        // +1 for Uncategorized
        Log.trace()
        let count = oldGroup == nil ? newGroups.count : newGroups.count + 1
        return count
    }
}
