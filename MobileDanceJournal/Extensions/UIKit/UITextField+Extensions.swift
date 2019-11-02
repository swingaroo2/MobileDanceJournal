//
//  UITextField+Extensions.swift
//  MobileDanceJournal
//
//  Created by Zach Lockett-Streiff on 7/3/19.
//  Copyright © 2019 Swingaroo2. All rights reserved.
//

import Foundation
import UIKit
import CoreData

extension UITextField {
    func configure(with managedObject: NSManagedObject, for keyPath: String) {
        Log.trace()
        let rawValue: Any? = managedObject.value(forKey: keyPath)
        text = rawValue as? String
        
        if keyPath.lowercased() == "date" {
            guard let date = rawValue as? Date else {
                Log.error("Failed to get a reference to date")
                return
            }
            let dateText = Date.getStringFromDate(date, .longFormat)
            text = dateText
        }
    }
}
