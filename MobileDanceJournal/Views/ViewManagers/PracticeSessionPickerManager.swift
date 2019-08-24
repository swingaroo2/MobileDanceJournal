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
    
    var managedPickerView: ToolbarPickerView
    var coreDataManager: CoreDataManager
    var practiceSessions: [PracticeSession]!
    var oldPracticeSession: PracticeSession!
    var videoToMove: PracticeVideo!
    
    init(_ managedView: ToolbarPickerView,_ coreDataManager: CoreDataManager) {
        self.managedPickerView = managedView
        self.coreDataManager = coreDataManager
    }
}

// MARK: - Picker delegate
extension PracticeSessionPickerManager: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let practiceSession = coreDataManager.practiceSessionFRC.object(at: IndexPath(row: row, section: component))
        return practiceSession.title
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
        
        let practiceSession = practiceSessions[row]
        label.text = practiceSession.title
        
        return label
    }
}

// MARK: - Picker data source
extension PracticeSessionPickerManager: UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        guard let practiceSessions = coreDataManager.practiceSessionFRC.fetchedObjects else { return 0 }
        let numberOfComponents = practiceSessions.count
        return numberOfComponents
    }
}

// MARK: - IBActions
extension PracticeSessionPickerManager {
    func doneButtonPressed() {
        let selectedPickerRow = managedPickerView.picker.selectedRow(inComponent: 0)
        let destinationPracticeSession = practiceSessions[selectedPickerRow]
        
        coreDataManager.move(videoToMove, from: oldPracticeSession, to: destinationPracticeSession)
        managedPickerView.hide()
    }
}
