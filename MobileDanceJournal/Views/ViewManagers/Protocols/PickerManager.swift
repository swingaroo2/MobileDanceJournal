//
//  PickerManager.swift
//  MobileDanceJournal
//
//  Created by Zach Lockett-Streiff on 8/24/19.
//  Copyright © 2019 Swingaroo2. All rights reserved.
//

import Foundation
import UIKit

protocol PickerManager: UIPickerViewDelegate, UIPickerViewDataSource {
    var managedPickerView: ToolbarPickerView { get }
    var coreDataManager: CoreDataManager { get }
    
    func doneButtonPressed()
}

extension PickerManager {
    func cancelButtonPressed() {
        managedPickerView.hide()
    }
}
