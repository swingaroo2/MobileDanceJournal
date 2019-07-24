//
//  PracticeVideo+Extensions.swift
//  MobileDanceJournal
//
//  Created by Zach Lockett-Streiff on 7/22/19.
//  Copyright © 2019 Swingaroo2. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

extension PracticeVideo {
    
    func getThumbnail() throws -> UIImage {
        do {
            let videoFilePath = URLBuilder.getDocumentsFilePathURL(for: filename)
            let asset = AVURLAsset(url: videoFilePath, options: nil)
            let imageGenerator = AVAssetImageGenerator(asset: asset)
            imageGenerator.appliesPreferredTrackTransform = true
            let thumbnailTimestamp = CMTimeMake(value: 0, timescale: 1)
            let cgThumbnail = try imageGenerator.copyCGImage(at: thumbnailTimestamp, actualTime: nil)
            let thumbnailImage = UIImage(cgImage: cgThumbnail)
            return thumbnailImage
        } catch {
            throw ThumbnailError.failedCopy
        }
    }
}
