//
//  PracticeNotepadVC+Extensions.swift
//  MobileDanceJournal
//
//  Created by Zach Lockett-Streiff on 7/3/19.
//  Copyright © 2019 Swingaroo2. All rights reserved.
//

import Foundation
import UIKit

// MARK: - View State Handlers
extension PracticeNotepadVC {
    func updateView(with practiceSession: PracticeSession) {
        practiceSessionTitleTextView.configure(with: practiceSession, for: PracticeSessionConstants.title)
        practiceSessionDateLabel.configure(with: practiceSession, for: PracticeSessionConstants.date)
        practiceSessionContent.configure(with: practiceSession, for: PracticeSessionConstants.notes)
    }

    func hideContent() {
        scrollView.isHidden = true
        noContentLabel.isHidden = false
        saveButton.isEnabled = false
        cameraButton.isEnabled = false
    }

    func showContent() {
        scrollView.isHidden = false
        noContentLabel.isHidden = true
    }
}

// MARK: - IBActions
extension PracticeNotepadVC {
    @IBAction func saveButtonPressed(_ sender: UIBarButtonItem) {
        practiceSessionTitleTextView.resignFirstResponder()
        practiceSessionContent.resignFirstResponder()
        saveButton.isEnabled = false
    }
    
    @IBAction func cameraButtonPressed(_ sender: UIBarButtonItem) {
        coordinator?.viewVideos(for: practiceSession)
    }
}
