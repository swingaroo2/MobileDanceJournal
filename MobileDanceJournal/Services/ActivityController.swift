

//
//  ShareController.swift
//  MobileDanceJournal
//
//  Created by Zach Lockett-Streiff on 10/12/19.
//  Copyright © 2019 Swingaroo2. All rights reserved.
//

import Foundation

public class ActivityController: NSObject {
    
    func share(_ video: PracticeVideo, _ coordinator: Coordinator) {
        let videoURL = URLBuilder.getDocumentsFilePathURL(for: video.filename)
        coordinator.share(videoURL)
    }
    
    func share(_ practiceSession: PracticeSession,_ coordinator: Coordinator) {}
    
    func share(_ group: Group,_ coordinator: Coordinator) {}
}
