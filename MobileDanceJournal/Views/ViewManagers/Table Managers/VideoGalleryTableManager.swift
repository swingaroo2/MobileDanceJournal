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
    
    var managedTableView: UITableView
    var managedVC: UIViewController
    
    var practiceSession: PracticeSession!
    var practiceSessionPicker: PracticeSessionPickerView!
    var noContentLabel: UILabel!
    var coordinator: VideoGalleryCoordinator!
    var videoToMove: PracticeVideo?
    
    required init(_ managedTableView: UITableView, managedVC: UIViewController) {
        Log.trace()
        self.managedTableView = managedTableView
        self.managedVC = managedVC
        super.init()
        self.managedTableView.tableFooterView = UIView()
        self.managedTableView.delegate = self
        self.managedTableView.dataSource = self
        Model.coreData.practiceVideoDelegate = self
    }
}

// MARK: - UITableViewDataSource
extension VideoGalleryTableManager: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let fetchedObjects = Model.coreData.fetchVideos(for: practiceSession)
        
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
        let video = Model.coreData.practiceVideoFRC.object(at: indexPath)
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
            deleteVideo(in: tableView, at: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        Log.trace()
        let deleteAction = UIContextualAction(style: .destructive, title: Actions.delete) { [unowned self] (action, view, completionHandler) in
            
            let deleteAlertAction: ((UIAlertAction) -> Void) = { action in
                let deleteSucceeded = self.deleteVideo(in: tableView, at: indexPath)
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
            
            guard let practiceSessions = Model.coreData.practiceSessionFRC.fetchedObjects else {
                Log.error("Failed to fetch Practice Logs")
                completionHandler(false)
                return
            }
            
            self.practiceSessionPicker = PracticeSessionPickerView(video, from: self.practiceSession, to: practiceSessions, managedView: self.managedVC.view)
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

// MARK: - Private Methods
private extension VideoGalleryTableManager {
    @discardableResult
    func deleteVideo(in tableView: UITableView, at indexPath: IndexPath) -> Bool {
        Log.trace()
        let videoToDelete = Model.coreData.practiceVideoFRC.object(at: indexPath)

        do {
            try Model.videoStorage.delete(videoToDelete)
            return true
        } catch {
            Log.error("Failed to delete video with error: \(error.localizedDescription)")
            return false
        }
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
