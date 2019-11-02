//
//  VideoGalleryTableManager.swift
//  MobileDanceJournal
//
//  Created by Zach Lockett-Streiff on 8/3/19.
//  Copyright © 2019 Swingaroo2. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class VideoGalleryTableManager: NSObject, TableManager {
    
    var coreDataManager: CoreDataManager
    var managedTableView: UITableView
    var managedVC: UIViewController
    
    var practiceSession: PracticeSession!
    var practiceSessionPicker: PracticeSessionPickerView!
    var noContentLabel: UILabel!
    var coordinator: VideoGalleryCoordinator!
    var videoToMove: PracticeVideo?
    
    required init(_ managedTableView: UITableView,_ coreDataManager: CoreDataManager, managedVC: UIViewController) {
        Log.trace()
        self.managedTableView = managedTableView
        self.coreDataManager = coreDataManager
        self.managedVC = managedVC
        super.init()
        self.managedTableView.tableFooterView = UIView()
        self.managedTableView.delegate = self
        self.managedTableView.dataSource = self
        self.coreDataManager.practiceVideoDelegate = self
    }
}

// MARK: - UITableViewDataSource
extension VideoGalleryTableManager: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let fetchedObjects = coreDataManager.fetchVideos(for: practiceSession)
        
        if let rightBarButtonItems = managedVC.navigationItem.rightBarButtonItems {
            rightBarButtonItems.forEach { button in
                if button.title == Actions.edit {
                   button.isEnabled = fetchedObjects.count > 0
                }
            }
        }
        
        let numRows = fetchedObjects.count

        UIView.transition(with: noContentLabel, duration: 0.4, options: .transitionCrossDissolve, animations: {
            self.noContentLabel.isHidden = numRows > 0
        })
        Log.trace("\(numRows) \(numRows != 1 ? "rows" : "row") in the Video Gallery table")
        return numRows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifiers.videoCell, for: indexPath) as! VideoGalleryTableViewCell
        let video = coreDataManager.practiceVideoFRC.object(at: indexPath)
        configure(cell, with: video)
        return cell
    }
    
    // MARK: UITableViewDataSource Helper Methods
    func configure(_ cell: VideoGalleryTableViewCell, with video: PracticeVideo) {
        Log.trace()
        cell.video = video
        cell.videoTitleLabel.text = video.title
        
        let url = URLBuilder.getDocumentsFilePathURL(for: video.filename)
        cell.videoThumbnail.setThumbnail(url)
    }
}

// MARK: - UITableViewDelegate
extension VideoGalleryTableManager: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        Log.trace()
        // Workaround for an Apple bug where setting the cell selection style to None (see storyboard) causes
        // an inconsistent delay in this code being run.
        DispatchQueue.main.async {
            guard let selectedCell = tableView.cellForRow(at: indexPath) as? VideoGalleryTableViewCell else {
                Log.error("Failed to get cell for row at Index Path: \(indexPath)")
                return
            }
            guard let video = selectedCell.video else {
                Log.error("Failed to get reference to the video in the selected cell")
                return
            }
            
            if !tableView.isEditing {
                self.coordinator?.play(video)
            } else {
                Services.uploads.set(video: video)
                self.coordinator?.startEditingVideo()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if let error = deleteVideo(in: tableView, at: indexPath) {
                managedVC.presentBasicAlert(title: UserErrors.deleteError, message: error.localizedDescription)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        Log.trace()
        let deleteAction = UIContextualAction(style: .destructive, title: Actions.delete) { [unowned self] (action, view, completionHandler) in
            
            let deleteAlertAction: ((UIAlertAction) -> Void) = { action in
                var deleteSucceeded = true
                if let error = self.deleteVideo(in: tableView, at: indexPath) {
                    self.managedVC.presentBasicAlert(title: UserErrors.deleteError, message: error.localizedDescription)
                    deleteSucceeded = false
                }
                completionHandler(deleteSucceeded)
            }
            
            let noAlertAction: ((UIAlertAction) -> Void) = { action in
                completionHandler(false)
            }
            
            self.managedVC.presentYesNoAlert(message: AlertConstants.confirmDelete, isDeleteAlert: true, yesAction: deleteAlertAction, noAction: noAlertAction)
            
        }
        
        let editAction = UIContextualAction(style: .normal, title: Actions.edit) { [unowned self] (action, view, completionHandler) in
            let selectedCell = tableView.cellForRow(at: indexPath) as! VideoGalleryTableViewCell
            
            guard let video = selectedCell.video else {
                Log.error("Failed to get reference to video in selected cell")
                completionHandler(false)
                return
            }
            
            Services.uploads.set(video: video)
            self.coordinator?.startEditingVideo()
            tableView.reloadRows(at: [indexPath], with: .fade)
            completionHandler(true)
        }
        // rgb(22, 60, 94)
        editAction.backgroundColor = .lightGray
        
        let shareAction = UIContextualAction(style: .normal, title: Actions.share) { (action, view, completionHandler) in
            let selectedCell = tableView.cellForRow(at: indexPath) as! VideoGalleryTableViewCell
            guard let video = selectedCell.video else {
                Log.error("Failed to get reference to video in selected cell")
                completionHandler(false)
                return
            }
            
            Services.activity.share(video, self.coordinator)
            completionHandler(true)
        }
        shareAction.backgroundColor = .darkGray
        
        let moveAction = UIContextualAction(style: .normal, title: Actions.move) { [unowned self] (action, view, completionHandler) in
            let selectedCell = tableView.cellForRow(at: indexPath) as! VideoGalleryTableViewCell
            guard let video = selectedCell.video else {
                Log.error("Failed to get reference to video in selected cell")
                return
            }
            self.videoToMove = video
            
            guard let practiceSessions = self.coreDataManager.practiceSessionFRC.fetchedObjects else {
                Log.error("Failed to fetch Practice Logs")
                completionHandler(false)
                return
            }
            
            self.practiceSessionPicker = PracticeSessionPickerView(video, from: self.practiceSession, to: practiceSessions, self.coreDataManager, managedView: self.managedVC.view)
            self.practiceSessionPicker.show()
            
            completionHandler(true)
        }
        moveAction.backgroundColor = .black
        
        var swipeActions = [deleteAction, editAction, shareAction, moveAction]
        
        if let fetchedPracticeSessions = practiceSession.group?.practiceSessions {
            if fetchedPracticeSessions.count == 1 {
                swipeActions = [deleteAction, editAction, shareAction]
            }
        }
        
        let swipeActionsConfig = UISwipeActionsConfiguration(actions: swipeActions)
        swipeActionsConfig.performsFirstActionWithFullSwipe = false
        return swipeActionsConfig
    }
}

private extension VideoGalleryTableManager {
    func deleteVideo(in tableView: UITableView, at indexPath: IndexPath) -> NSError? {
        Log.trace()
        let videoToDelete = coreDataManager.practiceVideoFRC.object(at: indexPath)
        
        guard let practiceSession = practiceSession else {
            Log.error("Failed to get reference to Practice Log")
            let noPracticeSessionError = NSError(domain: "VideoGallery", code: 0, userInfo: nil)
            noPracticeSessionError.setValue(UserErrors.noPracticeSession, forKey: NSLocalizedDescriptionKey)
            return noPracticeSessionError
        }
        
        if let error = VideoLocalStorageManager.delete(videoToDelete, from: practiceSession, coreDataManager) {
            return error
        }
        
        return nil
    }
}

// MARK: - NSFetchedResultsControllerDelegate
extension VideoGalleryTableManager: NSFetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch (type) {
        case .insert:
            if let indexPath = newIndexPath {
                managedTableView.insertRows(at: [indexPath], with: .fade)
            }
            break;
        case .delete:
            if let indexPath = indexPath {
                managedTableView.deleteRows(at: [indexPath], with: .fade)
            }
            break;
        case .update:
            if let indexPath = indexPath {
                managedTableView.reloadRows(at: [indexPath], with: .fade)
            }
            break;
        default:
            Log.error("\(#function): Unhandled case")
        }
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        Log.trace()
        managedTableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        Log.trace()
        managedTableView.endUpdates()
    }
}
