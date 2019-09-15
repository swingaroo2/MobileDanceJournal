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
    var videoHelper: VideoHelper?
    var videoToUpload: PracticeVideo?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUpView()
    }
    
    private func setUpView() {
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
    
    private func prepopulateTitle() {
        guard let videoHelper = videoHelper else { return }
        guard let video = videoHelper.uploadService.video else { return }
        titleTextField.text = video.title.isEmpty ? "" : video.title
    }
    
    private func configureThumbnail() {
        guard let videoHelper = videoHelper else { return }
        guard let url = videoHelper.uploadService.url else { return }
        videoHelper.getThumbnail(from: url) { image in
            self.thumbnail.image = image
        }
    }
    
}
