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
    var coreDataManager: CoreDataManager!
    var videoToUpload: PracticeVideo?
    
    // MARK: - Lifecycle Functions
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Log.trace()
        setUpView()
    }
}

// MARK: - Private Methods
private extension VideoUploadVC {
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
