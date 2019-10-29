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
        setUpView()
    }
}

// MARK: - Private Methods
private extension VideoUploadVC {
    func setUpView() {
        configureKeyboardToDismissOnOutsideTap()
        configureThumbnail()
        prepopulateTitle()
        
        titleTextField.becomeFirstResponder()
        
        guard let text = titleTextField.text else {
            saveButton.isEnabled = false
            return
        }
        
        saveButton.isEnabled = !text.isEmpty
    }
    
    func prepopulateTitle() {
        guard let video = Services.uploads.video else { return }
        titleTextField.text = video.title.isEmpty ? "" : video.title
    }
    
    func configureThumbnail() {
        guard let url = Services.uploads.url else { return }
        thumbnail.setThumbnail(url)
    }
}
