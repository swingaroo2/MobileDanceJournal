//
//  UIImageView+Extensions.swift
//  MobileDanceJournal
//
//  Created by Zach Lockett-Streiff on 7/22/19.
//  Copyright © 2019 Swingaroo2. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

extension UIImageView {
    
    // TODO: Is there a better way to do this?
    
    func setThumbnail(from video: PracticeVideo) throws {
        do {
            let thumbnailImage = try video.getThumbnail()
            image = thumbnailImage
        } catch ThumbnailError.failedCopy {
            throw ThumbnailError.failedCopy
        } catch {
            throw ThumbnailError.generic
        }
    }
    
    func setThumbnail(from path: URL) throws {
        do {
            let asset = AVURLAsset(url: path, options: nil)
            let imageGenerator = AVAssetImageGenerator(asset: asset)
            imageGenerator.appliesPreferredTrackTransform = true
            let thumbnailTimestamp = CMTimeMake(value: 0, timescale: 1)
            let cgThumbnail = try imageGenerator.copyCGImage(at: thumbnailTimestamp, actualTime: nil)
            let thumbnailImage = UIImage(cgImage: cgThumbnail)
            image = thumbnailImage
        } catch ThumbnailError.failedCopy {
            throw ThumbnailError.failedCopy
        } catch {
            throw ThumbnailError.generic
        }
    }
}

