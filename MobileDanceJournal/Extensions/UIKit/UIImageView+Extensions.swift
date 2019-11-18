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
    func setThumbnail(_ url: URL) {
        Log.trace()
        Services.uploads.getThumbnail(from: url) { cachedImage in
            DispatchQueue.main.async {
                self.image = cachedImage
            }
        }
    }
}

