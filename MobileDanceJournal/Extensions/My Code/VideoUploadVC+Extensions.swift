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
        guard let videoHelper = videoHelper else {
            presentBasicAlert(message: VideoUploadErrors.serviceUnavailable)
            coordinator?.dismiss(self, completion: nil)
            return
        }
        
        let uploadService = videoHelper.uploadService
        
        guard let videoURL = uploadService.url else {
            presentBasicAlert(message: VideoUploadErrors.lostVideo)
            coordinator?.dismiss(self, completion: nil)
            return
        }
        
        let titleText = titleTextField.text ?? "Title"
        let filename = videoURL.lastPathComponent
        
        let isEditingNewVideo = uploadService.video == nil
        
        if isEditingNewVideo {
            let newVideo = coreDataManager.createAndConfigureNewPracticeVideo(title: titleText, filename: filename)
            
            if let error = VideoLocalStorageManager.saveVideo(from: videoURL) {
                coordinator?.dismiss(self) { [weak self] in
                    guard let self = self else { return }
                    self.presentBasicAlert(title: VideoUploadErrors.generic, message: error.localizedDescription)
                }
                return
            }
            
            coordinator?.finishEditing(newVideo, from: uploadService)
            uploadService.set(video: nil)
        } else {
            guard let updatedVideo = uploadService.video else {
                coordinator?.dismiss(self, completion: nil)
                return
            }
            updatedVideo.title = titleText
            coordinator?.finishEditing(updatedVideo, from: uploadService)
            uploadService.set(video: nil)
        }
    }
    
    @IBAction func cancelUpload(_ sender: UIBarButtonItem) {
        videoHelper?.uploadService.set(video: nil)
        coordinator?.cancelUpload()
    }
    
    @IBAction func textDidChange(_ sender: UITextField) {
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
        textField.resignFirstResponder()
        return true
    }
}
