//
//  VideoGalleryVC.swift
//  MobileDanceJournal
//
//  Created by Zach Lockett-Streiff on 5/8/19.
//  Copyright © 2019 Swingaroo2. All rights reserved.
//

import UIKit

class VideoGalleryVC: UIViewController {

    var videoHelper: VideoHelper?
    var practiceSession: PracticeSession?
    var coordinator: MainCoordinator?
    var videoToMove: PracticeVideo?
    var practiceSessionPicker: PracticeSessionPickerView?
    
    @IBOutlet weak var noContentLabel: UILabel!
    @IBOutlet weak var videosTableView: UITableView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUpView()
        prefetchVideos(for: practiceSession)
    }
    
    private func setUpView() {
        navigationItem.title = VCConstants.videos
        CoreDataManager.shared.practiceVideoDelegate = self
        let addVideoImage = UIImage(named: CustomImages.addVideo)
        let addVideoButton = UIBarButtonItem.init(image: addVideoImage, landscapeImagePhone: addVideoImage, style: .plain, target: self, action: #selector(addVideoButtonPressed(_:)))
        navigationItem.rightBarButtonItems = [addVideoButton, editButtonItem]
        videosTableView.tableFooterView = UIView()
    }
    
}
