//
//  UISplitViewController+Extension.swift
//  MobileDanceJournal
//
//  Created by Zach Lockett-Streiff on 4/22/19.
//  Copyright © 2019 Swingaroo2. All rights reserved.
//

import UIKit

// MARK: - ViewController and NavigationController getters
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
    
    var masterVC: UIViewController? {
        return masterNC?.topViewController
    }
    
    var detailVC: UIViewController? {
        return detailNC?.topViewController
    }
    
    var isDisplayingBothVCs: Bool {
        return !isCollapsed && displayMode == .allVisible
    }
    
    var hasTwoRootNavigationControllers: Bool {
        return children.count == 2
    }
}
