//
//  Storyboarded.swift
//  MobileDanceJournal
//
//  Created by Zach Lockett-Streiff on 6/26/19.
//  Copyright © 2019 Swingaroo2. All rights reserved.
//

import UIKit

protocol Storyboarded {
    static func instantiate() -> Self
}

extension Storyboarded where Self: UIViewController {
    static func instantiate() -> Self {
        let fullName = NSStringFromClass(self)
        let className = fullName.components(separatedBy: ".")[1]
        Log.trace("Instantiating class from Storyboard: \(className)")
        let storyboard = UIStoryboard(name: Storyboards.main, bundle: Bundle.main)
        return storyboard.instantiateViewController(withIdentifier: className) as! Self
    }
}
