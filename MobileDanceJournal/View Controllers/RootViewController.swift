//
//  RootViewController.swift
//  MobileDanceJournal
//
//  Created by Zach Lockett-Streiff on 6/29/19.
//  Copyright © 2019 Swingaroo2. All rights reserved.
//

import Foundation
import UIKit

class RootViewController: UISplitViewController {

    weak var coordinator: Coordinator?
    
    override func viewDidLoad() {
        self.delegate = self
        self.preferredDisplayMode = .allVisible
    }
}

extension RootViewController: UISplitViewControllerDelegate {
    func splitViewController(_ splitViewController: UISplitViewController,
                             collapseSecondary secondaryViewController:UIViewController,
                             onto primaryViewController:UIViewController) -> Bool {
        guard let secondaryAsNavController = secondaryViewController as? UINavigationController else { return false }
        guard let topAsDetailController = secondaryAsNavController.topViewController as? PracticeNotepadVC else { return false }
        return topAsDetailController.practiceSession == nil
    }
}

extension RootViewController: Storyboarded {}
