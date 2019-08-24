//
//  PracticeSessionPickerView.swift
//  MobileDanceJournal
//
//  Created by Zach Lockett-Streiff on 7/23/19.
//  Copyright © 2019 Swingaroo2. All rights reserved.
//

import Foundation
import UIKit

class PracticeSessionPickerView: UIView, ToolbarPickerView {
    
    var picker: UIPickerView
    var manager: PickerManager!
    
    private var doneButton: UIBarButtonItem!
    private var cancelButton: UIBarButtonItem!
    
    required init(_ videoToMove: PracticeVideo, from oldPracticeLog: PracticeSession, to newPracticeLogs: [PracticeSession],_ coreDataManager: CoreDataManager, managedView: UIView) {
        self.picker = UIPickerView()
        super.init(frame: .zero)
        self.manager = self.configureManager(videoToMove, oldPracticeLog, newPracticeLogs, coreDataManager)
        self.picker.dataSource = self.manager
        self.picker.delegate = self.manager
        let toolbarButtons = configurePickerToolbarButtons()
        configureView(in: managedView, toolbarButtons)
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.picker = UIPickerView()
        super.init(coder: aDecoder)
    }
    
    private func configurePickerToolbarButtons() -> [UIBarButtonItem] {
        doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(actionButtonPressed))
        cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(actionButtonPressed))
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        return [doneButton, spacer, cancelButton]
    }
    
    private func configureManager(_ videoToMove: PracticeVideo,_ oldPracticeLog: PracticeSession,_ newPracticeLogs: [PracticeSession],_ coreDataManager: CoreDataManager) -> PracticeSessionPickerManager {
        let manager = PracticeSessionPickerManager(self, coreDataManager)
        manager.oldPracticeSession = oldPracticeLog
        manager.practiceSessions = newPracticeLogs
        manager.videoToMove = videoToMove
        return manager
    }
    
    @objc private func actionButtonPressed(_ sender: UIBarButtonItem) {
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
