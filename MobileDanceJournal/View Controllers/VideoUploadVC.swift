//
//  VideoUploadVC.swift
//  MobileDanceJournal
//
//  Created by Zach Lockett-Streiff on 7/10/19.
//  Copyright © 2019 Swingaroo2. All rights reserved.
//

import Foundation
import UIKit

class VideoUploadVC: UIViewController, Storyboarded {
    @IBOutlet weak var thumbnail: UIImageView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    weak var coordinator: VideoGalleryCoordinator?
    var videoToUpload: PracticeVideo?
    
    // MARK: - Lifecycle Functions
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Log.trace()
        setUpView()
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

// MARK: - IBActions
extension VideoUploadVC {
    @IBAction func completeUpload(_ sender: UIBarButtonItem) {
        Log.trace()
        guard let videoURL = Services.uploads.url else {
            presentBasicAlert(message: VideoUploadErrors.lostVideo)
            coordinator?.dismiss(self, completion: nil)
            return
        }
        updateModelAndFinishEditing(videoURL)
    }
    
    @IBAction func cancelUpload(_ sender: UIBarButtonItem) {
        Log.trace()
        Services.uploads.set(video: nil)
        coordinator?.cancelUpload()
    }
    
    @IBAction func textDidChange(_ sender: UITextField) {
        guard let title = sender.text else {
            Log.error("Failed to get reference to video title Text Field's text")
            saveButton.isEnabled = false
            return
        }
        
        saveButton.isEnabled = !title.isEmpty
    }
}

// MARK: - Private Methods
private extension VideoUploadVC {
    func updateModelAndFinishEditing(_ videoURL: URL) {
        let titleText = titleTextField.text ?? "Title"
        let filename = videoURL.lastPathComponent
        let isEditingNewVideo = Services.uploads.video == nil
        if isEditingNewVideo {
            let newVideo = Model.coreData.createAndConfigureNewPracticeVideo(title: titleText, filename: filename)
            saveVideoFile(at: videoURL)
            coordinator?.finishEditing(newVideo)
            Services.uploads.set(video: nil)
        } else {
            guard let updatedVideo = Services.uploads.video else {
                Log.error("Failed to get reference to updated Video")
                coordinator?.dismiss(self, completion: nil)
                return
            }
            updatedVideo.title = titleText
            coordinator?.finishEditing(updatedVideo)
            Services.uploads.set(video: nil)
        }
    }
    
    func saveVideoFile(at url: URL) {
        do {
            try Model.videoStorage.saveVideo(url)
            coordinator?.dismiss(self) { [weak self] in
                guard let self = self else {
                    Log.critical("Failed to get reference to self. That's weird.")
                    return
                }
                self.presentBasicAlert(title: VideoUploadErrors.generic, message: VideoUploadErrors.videoAlreadyExists)
            }
        } catch VideoStorageError.videoAlreadyExists(let filename) {
            Log.error("Video named \(filename) already exists in Documents directory")
        } catch {
            Log.error("Unexpected error: \(error.localizedDescription)")
        }
    }
    
    func setUpView() {
        Log.trace()
        configureKeyboardToDismissOnOutsideTap()
        configureThumbnail()
        prepopulateTitle()
        
        titleTextField.becomeFirstResponder()
        
        guard let text = titleTextField.text else {
            Log.critical("Failed to get reference to video title Text Field")
            saveButton.isEnabled = false
            return
        }
        
        saveButton.isEnabled = !text.isEmpty
    }
    
    func prepopulateTitle() {
        Log.trace()
        guard let video = Services.uploads.video else {
            Log.error("Failed to get reference to video. Cannot prepopulate video title")
            return
        }
        titleTextField.text = video.title.isEmpty ? "" : video.title
    }
    
    func configureThumbnail() {
        Log.trace()
        guard let url = Services.uploads.url else {
            Log.error("Failed to get reference to video URL. Cannot set video thumbnail")
            return
        }
        thumbnail.setThumbnail(url)
    }
}
