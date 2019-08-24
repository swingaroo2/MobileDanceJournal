//
//  PracticeLogCoordinator.swift
//  MobileDanceJournal
//
//  Created by Zach Lockett-Streiff on 8/22/19.
//  Copyright © 2019 Swingaroo2. All rights reserved.
//

import Foundation
import UIKit

class PracticeLogCoordinator: Coordinator {
    private let rootVC: SplitViewRootController
    private let coreDataManager: CoreDataManager
    private let currentGroup: Group?
    
    var childCoordinators = [Coordinator]()
    var navigationController = UINavigationController()
    
    init(_ rootViewController: SplitViewRootController,_ coreDataManager: CoreDataManager,_ currentGroup: Group?) {
        self.rootVC = rootViewController
        self.coreDataManager = coreDataManager
        self.currentGroup = currentGroup
    }
    
    func start() {
        let firstVC = PracticeLogVC.instantiate()
        firstVC.coordinator = self
        firstVC.coreDataManager = coreDataManager
        firstVC.currentGroup = currentGroup
        rootVC.masterNC?.pushViewController(firstVC, animated: true)
    }
    
    func isDisplayingBothVCs() -> Bool {
        return !rootVC.isCollapsed && rootVC.displayMode == .allVisible
    }
    
}

extension PracticeLogCoordinator {
    func startEditingNewPracticeSession() {
        let newPracticeSession = coreDataManager.insertAndReturnNewPracticeSession()
        showDetails(for: newPracticeSession)
    }
    
    func showDetails(for practiceSession: PracticeSession) {
        
        let detailVC = isDisplayingBothVCs() ? rootVC.detailVC : PracticeNotepadVC.instantiate()
        guard let notepadVC = detailVC else { return }
        
        notepadVC.coordinator = self
        notepadVC.coreDataManager = coreDataManager
        notepadVC.practiceSession = practiceSession
        notepadVC.navigationItem.leftBarButtonItem = rootVC.displayModeButtonItem
        notepadVC.navigationItem.leftItemsSupplementBackButton = true
        notepadVC.loadViewIfNeeded()
        notepadVC.textViewManager = NotepadTextViewManager(notepadVC, coreDataManager: coreDataManager)
        notepadVC.showContent()
        notepadVC.updateView(with: practiceSession)
        
        let detailNC = UINavigationController(rootViewController: notepadVC)
        rootVC.showDetailViewController(detailNC, sender: self)
    }
    
    // Special deletion case only applies when splitViewController is not collapsed
    func clearDetailVC() {
        guard let detailVC = rootVC.detailVC else { return }
        
        if !rootVC.isCollapsed {
            if let navController = detailVC.navigationController {
                let shouldPopBackToNotepadVC = detailVC != navController.topViewController && navController.children.contains(detailVC)
                if shouldPopBackToNotepadVC {
                    navController.popToViewController(detailVC, animated: false)
                }
            }
        }
        detailVC.practiceSession = nil
        detailVC.loadViewIfNeeded()
        detailVC.hideContent()
    }
    
    func viewVideos(for practiceSession: PracticeSession) {
        let child = VideoGalleryCoordinator(rootVC, coreDataManager, currentGroup, practiceSession)
        childCoordinators.append(child)
        child.start()
    }
}