//
//  NSObject+Extensions.swift
//  MobileDanceJournal
//
//  Created by Zach Lockett-Streiff on 7/15/19.
//  Copyright © 2019 Swingaroo2. All rights reserved.
//

import Foundation

extension NSObject {
    var documentsDirectory: URL {
        Log.trace()
        let pathURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return pathURL
    }
    
    var className: String {
        Log.trace()
        let fullName = NSStringFromClass(type(of: self))
        let className = fullName.components(separatedBy: ".")[1]
        return className
    }
}
