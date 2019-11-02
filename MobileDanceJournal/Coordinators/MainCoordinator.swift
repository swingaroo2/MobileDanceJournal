//
//  MainCoordinator.swift
//  MobileDanceJournal
//
//  Created by Zach Lockett-Streiff on 6/29/19.
//  Copyright © 2019 Swingaroo2. All rights reserved.
//

import Foundation

import UIKit

// MARK: - Initialization
class MainCoordinator: Coordinator {
    var rootVC: SplitViewRootController
    var childCoordinators: [Coordinator] = [Coordinator]()
    var navigationController = UINavigationController()
    private var coreDataManager: CoreDataManager
    
    init(_ rootViewController: SplitViewRootController,_ coreDataManager: CoreDataManager) {
        Log.trace()
        self.rootVC = rootViewController
        self.coreDataManager = coreDataManager
    }
    
    func start() {
        Log.trace()
        rootVC.coordinator = self
        let groupsVC = rootVC.masterVC as? PracticeGroupsVC
        let detailVC = rootVC.detailVC as? PracticeNotepadVC
        groupsVC?.coordinator = self
        groupsVC?.coreDataManager = coreDataManager
        detailVC?.coreDataManager = coreDataManager
        rootVC.detailNC!.topViewController!.navigationItem.leftBarButtonItem = rootVC.displayModeButtonItem
    }
    
    
}

// MARK: - Navigation functions
extension MainCoordinator {
    func showPracticeLog(group: Group?) {
        Log.trace("Showing practice log for group: \(group?.name ?? "NIL")")
        let child = PracticeLogCoordinator(rootVC, coreDataManager, group)
        childCoordinators.append(child)
        child.start()
    }
    
    func startEditing(group: Group?) {
        Log.trace("Starting to edit group: \(group?.name ?? "NIL")")
        let nextVC = NewGroupVC.instantiate()
        nextVC.coordinator = self
        nextVC.coreDataManager = coreDataManager
        nextVC.editingGroup = group
        rootVC.masterNC?.present(nextVC, animated: true, completion: nil)
    }
}
