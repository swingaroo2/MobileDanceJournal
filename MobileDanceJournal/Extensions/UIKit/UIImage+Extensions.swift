//
//  UIImage+Extensions.swift
//  MobileDanceJournal
//
//  Created by Zach Lockett-Streiff on 7/17/19.
//  Copyright © 2019 Swingaroo2. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {
    func scaleTo(_ newSize: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        self.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let newImage: UIImage? = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage ?? self
    }
}
