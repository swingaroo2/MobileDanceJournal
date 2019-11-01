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
        Log.trace()
        return viewControllers.first as? UINavigationController
    }
    
    var detailNC: UINavigationController? {
        Log.trace()
        if isCollapsed {
            guard let topNavController = children.first as? UINavigationController else { return nil }
            guard let detailNC = topNavController.children.last as? UINavigationController else { return nil }
            return detailNC
        }
        
        let childVC = viewControllers.count > 1 ? viewControllers.last : nil
        return childVC as? UINavigationController
    }
    
    var masterVC: UIViewController? {
        Log.trace()
        return masterNC?.topViewController
    }
    
    var detailVC: UIViewController? {
        Log.trace()
        return detailNC?.topViewController
    }
    
    var isDisplayingBothVCs: Bool {
        Log.trace()
        return !isCollapsed && displayMode == .allVisible
    }
    
    var hasTwoRootNavigationControllers: Bool {
        Log.trace()
        return children.count == 2
    }
}
