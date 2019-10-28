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
    
    func setThumbnail(_ video: PracticeVideo) {
        let thumbnailImage = Services.uploads.getThumbnail(video)
        image = thumbnailImage
    }
    
    func setThumbnail(_ path: URL) {
        Services.uploads.getThumbnail(from: path) { cachedImage in
            self.image = cachedImage
        }
    }
}

