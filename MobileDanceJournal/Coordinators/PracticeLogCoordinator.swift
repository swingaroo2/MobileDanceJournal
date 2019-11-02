//
//  PracticeLogCoordinator.swift
//  MobileDanceJournal
//
//  Created by Zach Lockett-Streiff on 8/22/19.
//  Copyright © 2019 Swingaroo2. All rights reserved.
//

import Foundation
import UIKit

// MARK: - Initialization
class PracticeLogCoordinator: Coordinator {
    let rootVC: SplitViewRootController
    private let coreDataManager: CoreDataManager
    let currentGroup: Group?
    
    var childCoordinators = [Coordinator]()
    var navigationController = UINavigationController()
    
    init(_ rootViewController: SplitViewRootController,_ coreDataManager: CoreDataManager,_ currentGroup: Group?) {
        Log.trace("Initializing Practice Log Coordinator for group: \(currentGroup?.name ?? "NIL")")
        self.rootVC = rootViewController
        self.coreDataManager = coreDataManager
        self.currentGroup = currentGroup
    }
    
    func start() {
        Log.trace()
        let firstVC = PracticeLogVC.instantiate()
        firstVC.coordinator = self
        firstVC.coreDataManager = coreDataManager
        firstVC.currentGroup = currentGroup
        rootVC.masterNC?.pushViewController(firstVC, animated: true)
    }
}

// MARK: - Navigation functions
extension PracticeLogCoordinator {
    func startEditingNewPracticeSession() {
        Log.trace()
        let newPracticeSession = coreDataManager.createAndReturnNewPracticeSession()
        newPracticeSession.group = currentGroup
        showDetails(for: newPracticeSession)
    }
    
    func showDetails(for practiceSession: PracticeSession) {
        Log.trace("Showing details for practice log: \(practiceSession.title)")
        let detailVC = rootVC.isDisplayingBothVCs ? rootVC.detailVC : PracticeNotepadVC.instantiate()
        guard let notepadVC = detailVC as? PracticeNotepadVC else {
            Log.error("PracticeNotepadVC is nil")
            return
        }
        
        notepadVC.coordinator = self
        notepadVC.coreDataManager = coreDataManager
        notepadVC.practiceSession = practiceSession
        notepadVC.navigationItem.leftBarButtonItem = rootVC.displayModeButtonItem
        notepadVC.navigationItem.leftItemsSupplementBackButton = true
        notepadVC.loadViewIfNeeded()
        notepadVC.textViewManager = NotepadTextViewManager(notepadVC, coreDataManager)
        notepadVC.showContent()
        notepadVC.updateView(with: practiceSession)
        
        let detailNC = UINavigationController(rootViewController: notepadVC)
        rootVC.showDetailViewController(detailNC, sender: self)
    }
    
    func clearDetailVC() {
        Log.trace()
        guard let detailVC = rootVC.detailVC as? PracticeNotepadVC else {
            Log.error("PracticeNotepadVC is nil")
            return
        }
        
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
        Log.trace("Viewing videos for practice log: \(practiceSession.title)")
        let child = VideoGalleryCoordinator(rootVC, coreDataManager, currentGroup, practiceSession)
        childCoordinators.append(child)
        child.start()
    }
}
