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
    
    func add(key: String, value: UIImage) {
        Log.trace()
        if object(forKey: key as NSString) == nil {
            setObject(value, forKey: key as NSString)
        } else {
         print("Unable to add thumbnail to cache")
        }
    }
    
    func value(for key: String) -> UIImage? {
        Log.trace()
        guard let thumbnail = object(forKey: key as NSString) else {
            print("Unable to retrieve thumbnail from cache")
            return nil
        }
        
        return thumbnail
    }

}
