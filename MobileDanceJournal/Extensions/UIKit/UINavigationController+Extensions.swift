//
//  UINavigationController+Extensions.swift
//  
//
//  Created by Zach Lockett-Streiff on 11/17/19.
//

import Foundation
import UIKit

extension UINavigationController {
    /**
      Returns a console-formatted string representation of the UINavigationController's children
     */
    var displayChildren: String {
        guard self.children.count > 0 else { return "[]" }
        
        let children = self.children.map { $0.className }
        return "\(children)"
    }
}
