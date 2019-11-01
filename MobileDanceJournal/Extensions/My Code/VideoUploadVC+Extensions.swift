//
//  VideoUploadVC+Extensions.swift
//  MobileDanceJournal
//
//  Created by Zach Lockett-Streiff on 7/17/19.
//  Copyright © 2019 Swingaroo2. All rights reserved.
//

import Foundation
import UIKit

// MARK: - IBActions
extension VideoUploadVC {
    @IBAction func completeUpload(_ sender: UIBarButtonItem) {
        Log.trace()
        guard let videoURL = Services.uploads.url else {
            presentBasicAlert(message: VideoUploadErrors.lostVideo)
            coordinator?.dismiss(self, completion: nil)
            return
        }
        
        let titleText = titleTextField.text ?? "Title"
        let filename = videoURL.lastPathComponent
        
        let isEditingNewVideo = Services.uploads.video == nil
        
        if isEditingNewVideo {
            let newVideo = coreDataManager.createAndConfigureNewPracticeVideo(title: titleText, filename: filename)
            
            if let error = VideoLocalStorageManager.saveVideo(from: videoURL) {
                coordinator?.dismiss(self) { [weak self] in
                    guard let self = self else { return }
                    self.presentBasicAlert(title: VideoUploadErrors.generic, message: error.localizedDescription)
                }
                return
            }
            
            coordinator?.finishEditing(newVideo)
            Services.uploads.set(video: nil)
        } else {
            guard let updatedVideo = Services.uploads.video else {
                coordinator?.dismiss(self, completion: nil)
                return
            }
            updatedVideo.title = titleText
            coordinator?.finishEditing(updatedVideo)
            Services.uploads.set(video: nil)
        }
    }
    
    @IBAction func cancelUpload(_ sender: UIBarButtonItem) {
        Log.trace()
        Services.uploads.set(video: nil)
        coordinator?.cancelUpload()
    }
    
    @IBAction func textDidChange(_ sender: UITextField) {
        Log.trace()
        guard let title = sender.text else {
            saveButton.isEnabled = false
            return
        }
        
        saveButton.isEnabled = !title.isEmpty
    }
}

// MARK: - UITextFieldDelegate
extension VideoUploadVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        Log.trace()
        textField.resignFirstResponder()
        return true
    }
}
