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
    var coreDataManager: CoreDataManager
    var practiceSessions: [PracticeSession]!
    var oldPracticeSession: PracticeSession!
    var videoToMove: PracticeVideo!
    
    required init(_ managedView: ToolbarPickerView,_ coreDataManager: CoreDataManager) {
        Log.trace()
        self.managedView = managedView
        self.coreDataManager = coreDataManager
    }
}

// MARK: UIPickerViewDelegate
extension PracticeSessionPickerManager: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        Log.trace()
        let practiceSession = practiceSessions[row]
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

// MARK: UIPickerViewDataSource
extension PracticeSessionPickerManager: UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        Log.trace()
        return practiceSessions.count
    }
}

// MARK: - IBActions
extension PracticeSessionPickerManager {
    func doneButtonPressed() {
        Log.trace()
        let selectedRow = managedView.picker.selectedRow(inComponent: 0)
        let destinationPracticeSession = practiceSessions[selectedRow]
        
        coreDataManager.move([videoToMove], from: oldPracticeSession, to: destinationPracticeSession)
        managedView.hide()
    }
}
