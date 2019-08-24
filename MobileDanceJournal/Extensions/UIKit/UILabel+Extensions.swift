//
//  UILabel+Extensions.swift
//  MobileDanceJournal
//
//  Created by Zach Lockett-Streiff on 7/3/19.
//  Copyright © 2019 Swingaroo2. All rights reserved.
//

import Foundation
import UIKit
import CoreData

extension UILabel {
    func configure(with managedObject: NSManagedObject, for keyPath: String) {
        
        let rawValue: Any? = managedObject.value(forKey: keyPath)
        text = rawValue as? String
        
        if keyPath.lowercased() == "date" {
            guard let date = rawValue as? Date else { return }
            let dateText = Date.getStringFromDate(date, .notepadDisplayFormat)
            text = dateText
        }
        
        // Legacy, if I ever re-add this to the data model
        if keyPath.lowercased() == "partners" {
            guard let partners = rawValue as? NSArray else { return }
            text = partners.componentsJoined(by: ", ")
        }
    }
}
