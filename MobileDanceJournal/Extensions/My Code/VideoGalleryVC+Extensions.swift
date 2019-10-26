//
//  VideoGalleryVC+Extension.swift
//  MobileDanceJournal
//
//  Created by Zach Lockett-Streiff on 5/8/19.
//  Copyright © 2019 Swingaroo2. All rights reserved.
//

import Foundation
import UIKit
import CoreData

// MARK: - General Behavior
extension VideoGalleryVC {
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        videosTableView.setEditing(editing, animated: animated)
    }
    
    func prefetchVideos(for practiceSession: PracticeSession?) {
        guard let practiceSession = self.practiceSession else { return }
        let fetchedVideos = coreDataManager.fetchVideos(for: practiceSession)
        noContentLabel.isHidden = !fetchedVideos.isEmpty
    }
}

// MARK: - IBActions
extension VideoGalleryVC {
    @IBAction func addVideoButtonPressed(_ sender: UIBarButtonItem) {
        presentAddVideoActionSheet(from: sender)
    }
}

// MARK: - UIImagePickerControllerDelegate
extension VideoGalleryVC: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let videoURL = info[.mediaURL] as? URL else {
            coordinator?.dismiss(picker) { [weak self] in
                self?.presentBasicAlert(title: VideoUploadErrors.generic, message: VideoUploadErrors.noURL)
            }
            return
        }
        videoHelper?.uploadService.url = videoURL
        coordinator?.startEditingVideo(videoHelper: videoHelper, videoPicker: picker)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        coordinator?.dismiss(picker) { print("\(#function)") }
    }
    
}

// MARK: - UINavigationControllerDelegate
extension VideoGalleryVC: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        viewController.navigationItem.title = VCConstants.chooseVideo
        print("\(#function)")
    }
}

// MARK: Helper functions
private extension VideoGalleryVC {
    func presentAddVideoActionSheet(from sender: UIBarButtonItem) {
        let actionSheet = AlertHelper.addVideoActionSheet()
        
        let recordVideoAction = UIAlertAction(title: AlertConstants.recordVideo, style: .default) { (action:UIAlertAction) in
            guard Services.permissions.hasCameraPermission() else { return }
            VideoHelper.initiate(.camera, in: self)
        }
        
        let uploadFromPhotosAction = UIAlertAction(title: AlertConstants.uploadFromPhotos, style: .default) { (action:UIAlertAction) in
            guard Services.permissions.hasPhotosPermission() else { return }
            VideoHelper.initiate(.photoLibrary, in: self)
        }
        
        actionSheet.addAction(recordVideoAction)
        actionSheet.addAction(uploadFromPhotosAction)
        
        if let popoverPresentationController: UIPopoverPresentationController = actionSheet.popoverPresentationController {
            popoverPresentationController.barButtonItem = sender
        }
        
        present(actionSheet, animated: true) { print("Presented Add Video action sheet") }
    }
}
