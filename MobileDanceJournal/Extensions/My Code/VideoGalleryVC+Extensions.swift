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
        Log.trace()
        super.setEditing(editing, animated: animated)
        videosTableView.setEditing(editing, animated: animated)
    }
    
    func prefetchVideos(for practiceSession: PracticeSession?) {
        Log.trace()
        guard let practiceSession = self.practiceSession else { return }
        let fetchedVideos = coreDataManager.fetchVideos(for: practiceSession)
        noContentLabel.isHidden = !fetchedVideos.isEmpty
    }
}

// MARK: - IBActions
extension VideoGalleryVC {
    @IBAction func addVideoButtonPressed(_ sender: UIBarButtonItem) {
        Log.trace()
        presentAddVideoActionSheet(from: sender)
    }
}

// MARK: - Helper functions
private extension VideoGalleryVC {
    func presentAddVideoActionSheet(from sender: UIBarButtonItem) {
        Log.trace()
        let actionSheet = AlertHelper.addVideoActionSheet()
        
        let recordVideoAction = UIAlertAction(title: AlertConstants.recordVideo, style: .default) { (action:UIAlertAction) in
            guard Services.permissions.hasCameraPermission() else { return }
            Services.uploads.recordVideo(from: self.coordinator)
        }
        
        let uploadFromPhotosAction = UIAlertAction(title: AlertConstants.uploadFromPhotos, style: .default) { (action:UIAlertAction) in
            guard Services.permissions.hasPhotosPermission() else { return }
            Services.uploads.uploadVideoFromPhotos(from: self.coordinator)
        }
        
        actionSheet.addAction(recordVideoAction)
        actionSheet.addAction(uploadFromPhotosAction)
        
        if let popoverPresentationController: UIPopoverPresentationController = actionSheet.popoverPresentationController {
            popoverPresentationController.barButtonItem = sender
        }
        
        present(actionSheet, animated: true) { print("Presented Add Video action sheet") }
    }
}
