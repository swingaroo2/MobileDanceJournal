//
//  PracticeNotepadVC+Extensions.swift
//  MobileDanceJournal
//
//  Created by Zach Lockett-Streiff on 7/3/19.
//  Copyright © 2019 Swingaroo2. All rights reserved.
//

import Foundation
import UIKit
import CoreData

// MARK: - UITextViewDelegate
extension PracticeNotepadVC: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.text = handleDefaultFieldText(in: textView)
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = getPlaceholderText(in: textView)
        } else {
            if !practiceSessionTitleTextView.text.isEmpty {
                save(practiceSession)
            }
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        handleState(of: saveButton, with: textView)
    }
    
}

// MARK: - UITextViewDelegate Helpers
extension PracticeNotepadVC {
    func handleDefaultFieldText(in textView: UITextView) -> String? {
        let textViewHasPlaceholderText = textView.text == PlaceholderText.newPracticeSession ||
            textView.text == PlaceholderText.tapToEditContent
        let placeholderText = textViewHasPlaceholderText ? "" : textView.text
        return placeholderText
    }
    
    func handleState(of button: UIBarButtonItem, with textView: UITextView) {
        let isSaveButton = button == saveButton
        button.isEnabled = (isSaveButton && !textView.text.isEmpty)
    }
    
    func getPlaceholderText(in textView: UITextView) -> String {
        if textView == practiceSessionTitleTextView {
            return PlaceholderText.newPracticeSession
        } else if textView == practiceSessionContent {
            return PlaceholderText.tapToEditContent
        } else {
            return ""
        }
    }
}

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

// MARK: - Core Data
extension PracticeNotepadVC {
    func save(_ practiceSession: PracticeSession?) {
        let practiceSessionToSave = (practiceSession == nil) ? coreDataManager.insertAndReturnNewPracticeSession() : practiceSession!
        
        practiceSessionToSave.title = practiceSessionTitleTextView.text
        practiceSessionToSave.notes = practiceSessionContent.text
        coreDataManager.save()
    }
}

//MARK: - Storyboarded
extension PracticeNotepadVC: Storyboarded {}
