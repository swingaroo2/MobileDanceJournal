//
//  VideoGalleryVC.swift
//  MobileDanceJournal
//
//  Created by Zach Lockett-Streiff on 5/8/19.
//  Copyright © 2019 Swingaroo2. All rights reserved.
//

import UIKit

class VideoGalleryVC: UIViewController, Storyboarded {

    var coreDataManager: CoreDataManager!
    var videoHelper: VideoHelper!
    var practiceSession: PracticeSession!
    var coordinator: MainCoordinator!
    var videoToMove: PracticeVideo?
    var practiceSessionPicker: PracticeSessionPickerView?
    var tableViewManager: VideoGalleryTableManager!
    
    @IBOutlet weak var noContentLabel: UILabel!
    @IBOutlet weak var videosTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTableManager()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUpView()
        prefetchVideos(for: practiceSession)
    }
    
    private func setUpTableManager() {
        videosTableView.delegate = tableViewManager
        videosTableView.dataSource = tableViewManager
        coreDataManager.practiceVideoDelegate = tableViewManager
        
        tableViewManager.tableView = videosTableView
        tableViewManager.practiceSession = practiceSession
        tableViewManager.practiceSessionPicker = practiceSessionPicker
        tableViewManager.noContentLabel = noContentLabel
        tableViewManager.videoHelper = videoHelper
        tableViewManager.coordinator = coordinator
        tableViewManager.videoToMove = videoToMove
    }
    
    private func setUpView() {
        navigationItem.title = VCConstants.videos
        let addVideoImage = UIImage(named: CustomImages.addVideo)
        let addVideoButton = UIBarButtonItem.init(image: addVideoImage, landscapeImagePhone: addVideoImage, style: .plain, target: self, action: #selector(addVideoButtonPressed(_:)))
        navigationItem.rightBarButtonItems = [addVideoButton, editButtonItem]
        videosTableView.tableFooterView = UIView()
    }
    
}
