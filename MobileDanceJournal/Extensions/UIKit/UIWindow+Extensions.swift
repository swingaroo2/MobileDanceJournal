//
//  UIWindow+Extensions.swift
//  MobileDanceJournal
//
//  Created by Zach Lockett-Streiff on 7/2/19.
//  Copyright © 2019 Swingaroo2. All rights reserved.
//

import Foundation
import UIKit

extension UIWindow {
    class func createNewWindow(with navController: UINavigationController) -> UIWindow {
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = navController
        window.makeKeyAndVisible()
        return window
    }
}
