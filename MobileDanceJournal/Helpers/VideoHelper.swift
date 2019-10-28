//
//  VideoPickerCoordinator.swift
//  MobileDanceJournal
//
//  Created by Zach Lockett-Streiff on 6/26/19.
//  Copyright © 2019 Swingaroo2. All rights reserved.
//

import Foundation
import UIKit
import Photos
import MobileCoreServices
import AVFoundation
import AVKit

class VideoHelper: NSObject {
    
    var uploadService: VideoUploadService
    let thumbnailCache: ThumbnailCache
    
    override init() {
        self.thumbnailCache = ThumbnailCache()
        self.uploadService = VideoUploadService()
        super.init()
    }
    
    init(with cache: ThumbnailCache, and uploadService: VideoUploadService) {
        self.thumbnailCache = cache
        self.uploadService = uploadService
    }
}
