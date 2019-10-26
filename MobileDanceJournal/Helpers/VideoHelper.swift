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
    
    func getThumbnail(from url: URL, completion: ((UIImage?) -> ())? = nil) {
        let filename = url.lastPathComponent
        
        if let cachedThumbnail = thumbnailCache.value(for: filename) {
            let thumbnail = cachedThumbnail
            completion?(thumbnail)
        } else {
            DispatchQueue.global(qos: .userInitiated).async {
                let thumbnail = self.uploadService.getThumbnail(from: url)
                DispatchQueue.main.async {
                    if let thumbnail = thumbnail {
                        self.thumbnailCache.add(key: filename, value: thumbnail)
                    }
                    completion?(thumbnail)
                }
            }
        }
    }
}
