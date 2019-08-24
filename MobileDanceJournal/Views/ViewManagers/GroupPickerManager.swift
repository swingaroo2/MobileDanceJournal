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
    var oldGroup: Group!
    var newGroups: [Group]!
    var practiceLogToMove: PracticeSession!
    
    required init(_ managedView: ToolbarPickerView, _ coreDataManager: CoreDataManager) {
        self.managedView = managedView
        self.coreDataManager = coreDataManager
    }
    
}

extension GroupPickerManager {
    func doneButtonPressed() {
        print(#function)
    }
}

extension GroupPickerManager {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return newGroups.count
    }
}
