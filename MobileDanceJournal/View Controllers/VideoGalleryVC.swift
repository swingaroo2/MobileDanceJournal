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
    
    override func viewDidLoad() {
        super.viewDidLoad()
         tableManager = setUpTableManager()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUpView()
        prefetchVideos(for: practiceSession)
    }
    
    private func setUpTableManager() -> VideoGalleryTableManager {
        let tableManager = VideoGalleryTableManager(videosTableView, coreDataManager, managedVC: self)
        tableManager.practiceSession = practiceSession
        tableManager.practiceSessionPicker = practiceSessionPicker
        tableManager.noContentLabel = noContentLabel
        tableManager.coordinator = coordinator
        tableManager.videoToMove = videoToMove
        return tableManager
    }
    
    private func setUpView() {
        navigationItem.title = VCConstants.videos
        let addVideoImage = UIImage(named: CustomImages.addVideo)
        let addVideoButton = UIBarButtonItem.init(image: addVideoImage, landscapeImagePhone: addVideoImage, style: .plain, target: self, action: #selector(addVideoButtonPressed(_:)))
        navigationItem.rightBarButtonItems = [addVideoButton, editButtonItem]
    }
    
}
