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
    
    func set(video: PracticeVideo) {
        self.video = video
        url = URLBuilder.getDocumentsFilePathURL(for: video.filename)
    }
    
    func getThumbnail(from videoFilePath: URL) -> UIImage? {
        do {
            let asset = AVURLAsset(url: videoFilePath, options: nil)
            let imageGenerator = AVAssetImageGenerator(asset: asset)
            imageGenerator.appliesPreferredTrackTransform = true
            let thumbnailTimestamp = CMTimeMake(value: 0, timescale: 1)
            let cgThumbnail = try imageGenerator.copyCGImage(at: thumbnailTimestamp, actualTime: nil)
            let thumbnail = UIImage(cgImage: cgThumbnail)
            return thumbnail
        } catch {
            print("Oops")
        }
        
        return nil
    }
    
    // TODO: Plan out architecture for CloudKit communication
}
