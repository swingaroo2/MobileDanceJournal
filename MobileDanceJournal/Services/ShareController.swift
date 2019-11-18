

//
//  ShareController.swift
//  MobileDanceJournal
//
//  Created by Zach Lockett-Streiff on 10/12/19.
//  Copyright © 2019 Swingaroo2. All rights reserved.
//

import Foundation

class ShareController: NSObject {
    
    func share(_ video: PracticeVideo, _ coordinator: VideoGalleryCoordinator) {
        Log.trace()
        let videoURL = URLBuilder.getDocumentsFilePathURL(for: video.filename)
        coordinator.share(videoURL)
    }
}
