//
//  UISplitViewController+Extension.swift
//  MobileDanceJournal
//
//  Created by Zach Lockett-Streiff on 4/22/19.
//  Copyright © 2019 Swingaroo2. All rights reserved.
//

import UIKit

// MARK: - ViewController and NavigationController getters
// TODO: Revisit this...shit's broke
extension UISplitViewController {
    var masterNC: UINavigationController? {
        return viewControllers.first as? UINavigationController
    }
    
    var detailNC: UINavigationController? {
        if isCollapsed {
            guard let topNavController = children.first as? UINavigationController else { return nil }
            guard let detailNC = topNavController.children.last as? UINavigationController else { return nil }
            return detailNC
        }
        
        let childVC = viewControllers.count > 1 ? viewControllers.last : nil
        return childVC as? UINavigationController
    }
    
    var masterVC: PracticeGroupsVC? {
        return masterNC?.topViewController as? PracticeGroupsVC
    }
    
    var detailVC: PracticeNotepadVC? {
        let childViewController = viewControllers.count > 1 ? viewControllers[1] : nil
        
        guard let childVC = childViewController as? UINavigationController else { return childViewController as? PracticeNotepadVC }
        guard let detailVC = childVC.children.first else { return childViewController as? PracticeNotepadVC }
        
        return detailVC as? PracticeNotepadVC
    }
}
