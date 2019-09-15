//
//  MainCoordinator.swift
//  MobileDanceJournal
//
//  Created by Zach Lockett-Streiff on 6/29/19.
//  Copyright © 2019 Swingaroo2. All rights reserved.
//

import Foundation

import UIKit

class MainCoordinator: Coordinator {
    var rootVC: SplitViewRootController
    var childCoordinators: [Coordinator] = [Coordinator]()
    var navigationController = UINavigationController()
    private var coreDataManager: CoreDataManager
    
    init(_ rootViewController: SplitViewRootController,_ coreDataManager: CoreDataManager) {
        self.rootVC = rootViewController
        self.coreDataManager = coreDataManager
    }
    
    func start() {
        rootVC.coordinator = self
        (rootVC.masterVC as? PracticeGroupsVC)?.coordinator = self
        (rootVC.masterVC as? PracticeGroupsVC)?.coreDataManager = coreDataManager
        rootVC.detailVC?.coreDataManager = coreDataManager
        rootVC.detailNC!.topViewController!.navigationItem.leftBarButtonItem = rootVC.displayModeButtonItem
    }
    
    func showPracticeLog(group: Group?) {
        let child = PracticeLogCoordinator(rootVC, coreDataManager, group)
        childCoordinators.append(child)
        child.start()
    }
    
    func startEditing(group: Group?) {
        let nextVC = NewGroupVC.instantiate()
        nextVC.coordinator = self
        nextVC.coreDataManager = coreDataManager
        nextVC.editingGroup = group
        rootVC.masterNC?.present(nextVC, animated: true, completion: nil)
    }
}
