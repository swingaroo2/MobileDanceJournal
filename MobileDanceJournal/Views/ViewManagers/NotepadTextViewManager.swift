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
    
    private let coreDataManager: CoreDataManager!
    private let notepadVC: PracticeNotepadVC
    
    init(_ notepadVC: PracticeNotepadVC,_ coreDataManager: CoreDataManager) {
        self.notepadVC = notepadVC
        self.coreDataManager = coreDataManager
        super.init()
        self.notepadVC.practiceSessionTitleTextView.delegate = self
        self.notepadVC.practiceSessionContent.delegate = self
    }
    
}

extension NotepadTextViewManager: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.text = handleDefaultFieldText(in: textView)
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
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

private extension NotepadTextViewManager {
    func handleDefaultFieldText(in textView: UITextView) -> String? {
        let textViewHasPlaceholderText = textView.text == PlaceholderText.newPracticeSession ||
            textView.text == PlaceholderText.tapToEditContent
        let placeholderText = textViewHasPlaceholderText ? "" : textView.text
        return placeholderText
    }
    
    func handleState(of button: UIBarButtonItem, with textView: UITextView) {
        let isSaveButton = button == notepadVC.saveButton
        button.isEnabled = (isSaveButton && !textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
    }
    
    func getPlaceholderText(in textView: UITextView) -> String {
        if textView == notepadVC.practiceSessionTitleTextView {
            return PlaceholderText.newPracticeSession
        } else if textView == notepadVC.practiceSessionContent {
            return PlaceholderText.tapToEditContent
        } else {
            return ""
        }
    }
    
    func save(_ practiceSession: PracticeSession?) {
        let practiceSessionToSave = (practiceSession == nil) ? coreDataManager.insertAndReturnNewPracticeSession() : practiceSession!
        
        practiceSessionToSave.title = notepadVC.practiceSessionTitleTextView.text
        practiceSessionToSave.notes = notepadVC.practiceSessionContent.text
        
        if let groupToUpdate = notepadVC.coordinator.currentGroup {
            coreDataManager.add([practiceSessionToSave], to: groupToUpdate)
        } else {
            coreDataManager.save()
        }
    }
}
