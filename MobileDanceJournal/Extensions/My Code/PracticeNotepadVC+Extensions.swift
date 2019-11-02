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
        Log.trace()
        practiceSessionTitleTextView.configure(with: practiceSession, for: PracticeSessionConstants.title)
        practiceSessionDateLabel.configure(with: practiceSession, for: PracticeSessionConstants.date)
        practiceSessionContent.configure(with: practiceSession, for: PracticeSessionConstants.notes)
    }

    func hideContent() {
        Log.trace()
        scrollView.isHidden = true
        noContentLabel.isHidden = false
        saveButton.isEnabled = false
        cameraButton.isEnabled = false
    }

    func showContent() {
        Log.trace()
        scrollView.isHidden = false
        noContentLabel.isHidden = true
    }
}

// MARK: - IBActions
extension PracticeNotepadVC {
    @IBAction func saveButtonPressed(_ sender: UIBarButtonItem) {
        Log.trace()
        practiceSessionTitleTextView.resignFirstResponder()
        practiceSessionContent.resignFirstResponder()
        saveButton.isEnabled = false
    }
    
    @IBAction func cameraButtonPressed(_ sender: UIBarButtonItem) {
        Log.trace()
        coordinator?.viewVideos(for: practiceSession)
    }
}
