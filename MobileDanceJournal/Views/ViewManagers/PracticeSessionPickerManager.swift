//
//  PracticeSessionPickerManager.swift
//  MobileDanceJournal
//
//  Created by Zach Lockett-Streiff on 8/3/19.
//  Copyright © 2019 Swingaroo2. All rights reserved.
//

import Foundation
import UIKit

class PracticeSessionPickerManager: NSObject, PickerManager {
    
    var managedView: ToolbarPickerView
    var practiceSessions: [PracticeSession]!
    var oldPracticeSession: PracticeSession!
    var videoToMove: PracticeVideo!
    
    required init(_ managedView: ToolbarPickerView) {
        Log.trace()
        self.managedView = managedView
    }
}

// MARK: - UIPickerViewDelegate
extension PracticeSessionPickerManager: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var label: UILabel
        let isGroupsComponent = component == PickerComponents.groups.rawValue
        let isPracticeSessionComponent = component == PickerComponents.practiceSessions.rawValue
        
        if let view = view as? UILabel {
            label = view
        } else {
            label = UILabel()
        }
        
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont(name: "Menlo-Regular", size: 17)
        label.text = "ERROR"
        
        guard let fetchedGroups = Model.coreData.groupFRC.fetchedObjects else {
            Log.error("Failed to fetch Groups")
            return label
        }
        
        if isGroupsComponent {
            let isUncategorizedGroupRow = row == fetchedGroups.count
            let titleForRow: String = isUncategorizedGroupRow ? TextConstants.uncategorized : fetchedGroups[row].name
            label.text = titleForRow
        } else if isPracticeSessionComponent {
            let selectedGroupRow = pickerView.selectedRow(inComponent: PickerComponents.groups.rawValue)
            let isUncategorizedGroupRow = selectedGroupRow == fetchedGroups.count
            let selectedGroup = isUncategorizedGroupRow ? nil : Model.coreData.groupFRC.object(at: IndexPath(row: selectedGroupRow, section: 0))
            guard let practiceSessionsForGroup = Model.coreData.fetchPracticeSessions(in: selectedGroup, excluding: videoToMove.practiceSession) else {
                Log.error("Failed to fetch Practice Sessions for Group")
                return label
            }
            let practiceSessionForRow = practiceSessionsForGroup[row]
            let titleForRow = practiceSessionForRow.title
            label.text = titleForRow
        }
        
        Log.trace("View for row \(row) in component \(component): UILabel with text \(label.text!)")
        return label
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let isGroupsComponent = component == PickerComponents.groups.rawValue
        if isGroupsComponent {
            pickerView.reloadComponent(PickerComponents.practiceSessions.rawValue)
        }
    }
}

// MARK: - UIPickerViewDataSource
extension PracticeSessionPickerManager: UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        let numComponents = PickerComponents.count
        Log.trace("\(numComponents) \(numComponents != 1 ? "components" : "component") in the Practice Session Picker")
        return numComponents
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        var numRows = 0
        let isGroupsComponent = component == PickerComponents.groups.rawValue
        let isPracticeSessionComponent = component == PickerComponents.practiceSessions.rawValue
        
        if isGroupsComponent {
            // NOTE: Need to account for extra Uncategorized Group
            guard let fetchedGroups = Model.coreData.groupFRC.fetchedObjects else {
                Log.error("Failed to fetch Groups")
                numRows = 1
                return numRows
            }
            
            numRows = fetchedGroups.count + 1
            Log.trace("\(numRows) \(numRows != 1 ? "groups" : "group")")
            return numRows
        } else if isPracticeSessionComponent {
            
            let selectedGroupRow = pickerView.selectedRow(inComponent: PickerComponents.groups.rawValue)
            
            guard let fetchedGroups = Model.coreData.groupFRC.fetchedObjects else {
                Log.error("Failed to fetch Groups")
                return numRows
            }
            
            // NOTE: Uncategorized Group is always at the end
            let uncategorizedGroupIsSelected = selectedGroupRow == fetchedGroups.count
            let selectedGroup = uncategorizedGroupIsSelected ? nil : Model.coreData.groupFRC.object(at: IndexPath(row: selectedGroupRow, section: 0))
            
            guard let practiceSessionsForGroup = Model.coreData.fetchPracticeSessions(in: selectedGroup, excluding: oldPracticeSession!) else {
                Log.error("Failed to fetch Practice Sessions for Group")
                return numRows
            }
            
            numRows = practiceSessionsForGroup.count
            Log.trace("\(numRows) \(numRows != 1 ? "practice sessions" : "practice session")")
            return numRows
        }
        
        Log.error("Failed to get the row count for component \(component)")
        return numRows
    }
}

// MARK: - IBActions
extension PracticeSessionPickerManager {
    func doneButtonPressed() {
        Log.trace()
        guard let fetchedGroups = Model.coreData.groupFRC.fetchedObjects else {
            Log.error("Failed to fetch Groups")
            return
        }
        
        let selectedGroupRow = managedView.picker.selectedRow(inComponent: PickerComponents.groups.rawValue)
        let selectedGroupIndexPath = IndexPath(row: selectedGroupRow, section: 0)
        let selectedGroup = selectedGroupRow == fetchedGroups.count ? nil : Model.coreData.groupFRC.object(at: selectedGroupIndexPath)
        
        guard let selectedGroupPracticeSessions = Model.coreData.fetchPracticeSessions(in: selectedGroup, excluding: videoToMove.practiceSession) else {
            Log.error("Failed to fetch Practice Sessions")
            return
        }
        
        let selectedPracticeSessionRow = managedView.picker.selectedRow(inComponent: PickerComponents.practiceSessions.rawValue)
        let newPracticeSession = selectedGroupPracticeSessions[selectedPracticeSessionRow]
        
        Model.coreData.move(videoToMove, to: newPracticeSession)
        managedView.hide()
    }
}
