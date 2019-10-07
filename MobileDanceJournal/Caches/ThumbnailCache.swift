//
//  ThumbnailCache.swift
//  MobileDanceJournal
//
//  Created by Zach Lockett-Streiff on 7/22/19.
//  Copyright © 2019 Swingaroo2. All rights reserved.
//

import Foundation
import UIKit

class ThumbnailCache: NSCache<NSString,UIImage> {
    
    // TODO: Consider throwing exceptions for failure cases
    func add(key: String, value: UIImage) {
        if object(forKey: key as NSString) == nil {
            setObject(value, forKey: key as NSString)
        } else {
         print("Unable to add thumbnail to cache")
        }
    }
    
    func value(for key: String) -> UIImage? {
        guard let thumbnail = object(forKey: key as NSString) else {
            print("Unable to retrieve thumbnail from cache")
            return nil
        }
        
        return thumbnail
    }

}
