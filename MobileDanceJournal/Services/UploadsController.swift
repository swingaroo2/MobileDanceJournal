//
//  UploadsController.swift
//  MobileDanceJournal
//
//  Created by Zach Lockett-Streiff on 10/26/19.
//  Copyright © 2019 Swingaroo2. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

class UploadsController: NSObject {
    
    let thumbnailCache = ThumbnailCache()
    
    var thumbnailImage: UIImage?
    var tmpPath: URL?
    var url: URL?
    var video: PracticeVideo?
    
    // MARK: - Setters
    func set(filename: String) {
        Log.trace()
        self.url = URLBuilder.getDocumentsFilePathURL(for: filename)
    }
    
    func set(url: URL) {
        Log.trace()
        self.url = url
    }
    
    func set(video: PracticeVideo?) {
        Log.trace()
        self.video = video
        guard let video = video else { return }
        self.url = URLBuilder.getDocumentsFilePathURL(for: video.filename)
    }
    
    // MARK: - Add Video Operations
    func recordVideo(from coordinator: VideoGalleryCoordinator) {
        Log.trace()
        coordinator.initiate(.camera)
    }
    
    func uploadVideoFromPhotos(from coordinator: VideoGalleryCoordinator) {
        Log.trace()
        coordinator.initiate(.photoLibrary)
    }
    
    // MARK: - Thumbnails
    func getThumbnail(from url: URL, completion: ((UIImage?) -> ())? = nil) {
        Log.trace()
        let filename = url.lastPathComponent
        
        if let cachedThumbnail = thumbnailCache.value(for: filename) {
            let thumbnail = cachedThumbnail
            completion?(thumbnail)
        } else {
            DispatchQueue.global(qos: .userInitiated).async {
                let thumbnail = self.getThumbnail(url)
                DispatchQueue.main.async {
                    if let thumbnail = thumbnail {
                        self.thumbnailCache.add(key: filename, value: thumbnail)
                    }
                    completion?(thumbnail)
                }
            }
        }
    }
    
    func getThumbnail(_ video: PracticeVideo) -> UIImage? {
        Log.trace()
        let videoFilePath = URLBuilder.getDocumentsFilePathURL(for: video.filename)
        let thumbnailImage = getThumbnail(videoFilePath)
        return thumbnailImage
    }
}

private extension UploadsController {
    func getThumbnail(_ videoFilePath: URL) -> UIImage? {
        Log.trace()
        let asset = AVURLAsset(url: videoFilePath, options: nil)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true
        let thumbnailTimestamp = CMTimeMake(value: 0, timescale: 1)
        guard let cgThumbnail = try? imageGenerator.copyCGImage(at: thumbnailTimestamp, actualTime: nil) else { return nil }
        let thumbnail = UIImage(cgImage: cgThumbnail)
        return thumbnail
    }
}
