//
//  UITextView+Extensions.swift
//  MobileDanceJournal
//
//  Created by Zach Lockett-Streiff on 7/3/19.
//  Copyright © 2019 Swingaroo2. All rights reserved.
//

import Foundation
import UIKit
import CoreData

extension UITextView {
    func configure(with managedObject: NSManagedObject, for keyPath: String) {
        Log.trace()
        let rawValue = managedObject.value(forKey: keyPath)
        text = rawValue as? String
        
        if keyPath.lowercased() == PracticeSessionConstants.title {
            text = (rawValue == nil) ? PlaceholderText.newPracticeSession : (rawValue as? String)
        } else if keyPath.lowercased() == PracticeSessionConstants.notes {
            text = (rawValue == nil) ? PlaceholderText.tapToEditContent : (rawValue as? String)
        }
    }
}
