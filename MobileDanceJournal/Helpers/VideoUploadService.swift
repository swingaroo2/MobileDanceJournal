//
//  VideoUploadService.swift
//  MobileDanceJournal
//
//  Created by Zach Lockett-Streiff on 7/16/19.
//  Copyright © 2019 Swingaroo2. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

class VideoUploadService: NSObject {
    
    var thumbnailImage: UIImage?
    var tmpPath: URL?
    var url: URL?
    var video: PracticeVideo?
    
    override init() {
        super.init()
    }
    
    init(url: URL) {
        self.url = url
        super.init()
    }
    
    init(filename: String) {
        self.url = URLBuilder.getDocumentsFilePathURL(for: filename)
        super.init()
    }
    
    init(video: PracticeVideo) {
        self.video = video
        self.url = URLBuilder.getDocumentsFilePathURL(for: video.filename)
        super.init()
    }
    
    func set(video: PracticeVideo?) {
        self.video = video
        guard let video = video else { return }
        url = URLBuilder.getDocumentsFilePathURL(for: video.filename)
    }
    
}
