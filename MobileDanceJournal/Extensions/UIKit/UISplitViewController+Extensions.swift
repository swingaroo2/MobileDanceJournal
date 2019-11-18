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
        let navController = viewControllers.first as? UINavigationController
        Log.trace("MasterNC Children: \(navController == nil ? "NIL" : navController!.displayChildren)")
        return viewControllers.first as? UINavigationController
    }
    
    var detailNC: UINavigationController? {
        if isCollapsed {
            guard let topNavController = children.first as? UINavigationController else {
                Log.error("Failed to get a reference to top Navigation Controller")
                return nil
            }
            guard let detailNC = topNavController.children.last as? UINavigationController else {
                Log.warn("Failed to get a reference to detail Navigation Controller")
                return nil
            }
            Log.trace("DetailNC Children: \(detailNC.displayChildren)")
            return detailNC
        }
        
        let childVC = viewControllers.count > 1 ? viewControllers.last : nil
        let navController = childVC as? UINavigationController
        
        Log.trace("DetailNC Children: \(navController == nil ? "NIL" : navController!.displayChildren)")
        
        return navController
    }
    
    var masterVC: UIViewController? {
        guard let masterNC = masterNC else {
            Log.trace("NIL masterNC")
            return nil
        }
        
        guard let topVC = masterNC.topViewController else {
            Log.trace("NIL topViewController")
            return nil
        }
        
        Log.trace("MasterVC: \(topVC.className)")
        return topVC
    }
    
    var detailVC: UIViewController? {
        guard let detailNC = detailNC else {
            Log.trace("NIL masterNC")
            return nil
        }
        
        guard let topVC = detailNC.topViewController else {
            Log.trace("NIL topViewController")
            return nil
        }
        
        Log.trace("DetailVC: \(topVC.className)")
        return topVC
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
