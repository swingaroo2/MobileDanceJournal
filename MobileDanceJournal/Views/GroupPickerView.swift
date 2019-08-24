//
//  GroupPickerView.swift
//  MobileDanceJournal
//
//  Created by Zach Lockett-Streiff on 8/24/19.
//  Copyright © 2019 Swingaroo2. All rights reserved.
//

import Foundation
import UIKit

class GroupPickerView: UIView, ToolbarPickerView {
    var picker: UIPickerView = UIPickerView()
    var manager: PickerManager!
    
    private var doneButton: UIBarButtonItem!
    private var cancelButton: UIBarButtonItem!
    
    required init(_ practiceLogToMove: PracticeSession,_ oldGroup: Group,_ newGroups: [Group],_ coreDataManager: CoreDataManager, managedView: UIView) {
        // blah
        super.init(frame: .zero)
        self.manager = self.configureManager(practiceLogToMove, oldGroup, newGroups, coreDataManager)
        self.picker.dataSource = self.manager
        self.picker.delegate = self.manager
        let toolbarButtons = configurePickerToolbarButtons()
        configureView(in: managedView, toolbarButtons)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}

private extension GroupPickerView {
    func configurePickerToolbarButtons() -> [UIBarButtonItem] {
        doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(actionButtonPressed))
        cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(actionButtonPressed))
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        return [doneButton, spacer, cancelButton]
    }
    
    func configureManager(_ practiceLogToMove: PracticeSession,_ oldGroup: Group,_ newGroups: [Group],_ coreDataManager: CoreDataManager) -> GroupPickerManager {
        let manager = GroupPickerManager(self, coreDataManager)
        manager.practiceLogToMove = practiceLogToMove
        manager.oldGroup = oldGroup
        manager.newGroups = newGroups.filter { $0 != oldGroup }
        return manager
    }
}

private extension GroupPickerView {
    @objc func actionButtonPressed(_ sender: UIBarButtonItem) {
        switch sender {
        case doneButton:
            manager.doneButtonPressed()
        case cancelButton:
            manager.cancelButtonPressed()
        default:
            break
        }
    }
}
