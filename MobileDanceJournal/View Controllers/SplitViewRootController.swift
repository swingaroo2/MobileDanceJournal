//
//  RootViewController.swift
//  MobileDanceJournal
//
//  Created by Zach Lockett-Streiff on 6/29/19.
//  Copyright © 2019 Swingaroo2. All rights reserved.
//

import Foundation
import UIKit

class SplitViewRootController: UISplitViewController, Storyboarded {

    weak var coordinator: MainCoordinator?
    var coreDataManager: CoreDataManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Log.trace()
        self.delegate = self
        self.preferredDisplayMode = .allVisible
    }
}

extension SplitViewRootController: UISplitViewControllerDelegate {
    func splitViewController(_ splitViewController: UISplitViewController,
                             collapseSecondary secondaryViewController:UIViewController,
                             onto primaryViewController:UIViewController) -> Bool
    {
        Log.trace()
        guard let secondaryAsNavController = secondaryViewController as? UINavigationController else {
            Log.error("Failed to get reference to secondary Navigation Controller")
            return false
        }
        guard let topAsDetailController = secondaryAsNavController.topViewController as? PracticeNotepadVC else {
            Log.error("Failed to get reference to PracticeNotepadVC as detail View Controller")
            return false
        }
        return topAsDetailController.practiceSession == nil
    }
}
