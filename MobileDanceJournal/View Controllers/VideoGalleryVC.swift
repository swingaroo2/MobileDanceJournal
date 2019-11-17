//
//  VideoGalleryVC.swift
//  MobileDanceJournal
//
//  Created by Zach Lockett-Streiff on 5/8/19.
//  Copyright © 2019 Swingaroo2. All rights reserved.
//

import UIKit

class VideoGalleryVC: UIViewController, Storyboarded {

    var coordinator: VideoGalleryCoordinator!
    var coreDataManager: CoreDataManager!
    var tableManager: TableManager!
    var practiceSession: PracticeSession!
    var practiceSessionPicker: PracticeSessionPickerView?
    var videoToMove: PracticeVideo?
    
    @IBOutlet weak var noContentLabel: UILabel!
    @IBOutlet weak var videosTableView: UITableView!
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        Log.trace()
         tableManager = setUpTableManager()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Log.trace()
        setUpView()
        prefetchVideos(for: practiceSession)
    }
    
}

extension VideoGalleryVC {
    override func setEditing(_ editing: Bool, animated: Bool) {
        Log.trace()
        super.setEditing(editing, animated: animated)
        videosTableView.setEditing(editing, animated: animated)
    }
    
    func prefetchVideos(for practiceSession: PracticeSession?) {
        Log.trace()
        guard let practiceSession = self.practiceSession else {
            Log.error("Failed to get reference to Practice Log")
            return
        }
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
        
        present(actionSheet, animated: true) { Log.trace("Presented Add Video action sheet") }
    }
}

// MARK: - Private Methods
private extension VideoGalleryVC {
    func setUpTableManager() -> VideoGalleryTableManager {
        Log.trace()
        let tableManager = VideoGalleryTableManager(videosTableView, coreDataManager, managedVC: self)
        tableManager.practiceSession = practiceSession
        tableManager.practiceSessionPicker = practiceSessionPicker
        tableManager.noContentLabel = noContentLabel
        tableManager.coordinator = coordinator
        tableManager.videoToMove = videoToMove
        return tableManager
    }
    
    func setUpView() {
        Log.trace()
        navigationItem.title = VCConstants.videos
        let addVideoImage = UIImage(named: CustomImages.addVideo)
        let addVideoButton = UIBarButtonItem.init(image: addVideoImage, landscapeImagePhone: addVideoImage, style: .plain, target: self, action: #selector(addVideoButtonPressed(_:)))
        navigationItem.rightBarButtonItems = [addVideoButton, editButtonItem]
    }
}
