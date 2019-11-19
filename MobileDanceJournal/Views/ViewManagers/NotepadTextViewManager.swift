//
//  NotepadTextViewManager.swift
//  MobileDanceJournal
//
//  Created by Zach Lockett-Streiff on 8/3/19.
//  Copyright © 2019 Swingaroo2. All rights reserved.
//

import Foundation
import UIKit

class NotepadTextViewManager: NSObject {
    
    private let notepadVC: PracticeNotepadVC
    
    init(_ notepadVC: PracticeNotepadVC) {
        Log.trace()
        self.notepadVC = notepadVC
        super.init()
        self.notepadVC.practiceSessionTitleTextView.delegate = self
        self.notepadVC.practiceSessionContent.delegate = self
    }
    
}

// MARK: - UITextViewDelegate
extension NotepadTextViewManager: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        Log.trace()
        textView.text = handleDefaultFieldText(in: textView)
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        Log.trace()
        if textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            textView.text = getPlaceholderText(in: textView)
        } else {
            if !notepadVC.practiceSessionTitleTextView.text.isEmpty {
                save(notepadVC.practiceSession)
            }
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        handleState(of: notepadVC.saveButton, with: textView)
    }
    
}

// MARK: - Private Methods
private extension NotepadTextViewManager {
    /**
     Determines the state of default text in both UITextViews in the notepad
     */
    func handleDefaultFieldText(in textView: UITextView) -> String? {
        Log.trace()
        let textViewHasPlaceholderText = textView.text == PlaceholderText.newPracticeSession ||
            textView.text == PlaceholderText.tapToEditContent
        let placeholderText = textViewHasPlaceholderText ? "" : textView.text
        return placeholderText
    }
    
    /**
     Determines the state of the save button in the notepad
     */
    func handleState(of button: UIBarButtonItem, with textView: UITextView) {
        let isSaveButton = button == notepadVC.saveButton
        button.isEnabled = (isSaveButton && !textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
    }
    
    func getPlaceholderText(in textView: UITextView) -> String {
        Log.trace()
        if textView == notepadVC.practiceSessionTitleTextView {
            return PlaceholderText.newPracticeSession
        } else if textView == notepadVC.practiceSessionContent {
            return PlaceholderText.tapToEditContent
        } else {
            return ""
        }
    }
    
    /**
     Updates the model and posts a notification to update the practice log's TableManager
     */
    func save(_ practiceSession: PracticeSession) {
        Log.trace()
        practiceSession.title = notepadVC.practiceSessionTitleTextView.text
        practiceSession.notes = notepadVC.practiceSessionContent.text
        Model.coreData.save()
        NotificationCenter.default.post(name: .practiceLogUpdated, object: nil, userInfo: [Notification.Name.practiceLogUpdated : practiceSession])
    }
}
