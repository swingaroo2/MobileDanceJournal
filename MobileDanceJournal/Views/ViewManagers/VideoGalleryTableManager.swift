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

class VideoGalleryTableManager: NSObject {
    
    private let coreDataManager: CoreDataManager!
    private let managedVC: UIViewController
    var tableView: UITableView!
    var practiceSession: PracticeSession!
    var practiceSessionPicker: PracticeSessionPickerView!
    var noContentLabel: UILabel!
    var videoHelper: VideoHelper!
    var coordinator: MainCoordinator!
    var videoToMove: PracticeVideo?
    
    init(_ managedVC: UIViewController, coreDataManager: CoreDataManager) {
        self.managedVC = managedVC
        self.coreDataManager = coreDataManager
    }
}

// MARK: - UITableViewDataSource
extension VideoGalleryTableManager: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let fetchedObjects = coreDataManager.practiceVideoFRC.fetchedObjects
        
        if let rightBarButtonItems = managedVC.navigationItem.rightBarButtonItems {
            rightBarButtonItems.forEach { button in
                if button.title == Actions.edit {
                    if let fetchedVideos = fetchedObjects {
                        button.isEnabled = fetchedVideos.count > 0
                    } else {
                        button.isEnabled = false
                    }
                }
            }
            
        }
        
        guard let fetchedVideos = fetchedObjects else { return 0 }
        let count = fetchedVideos.count
        
        noContentLabel.isHidden = (count > 0)
        
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifiers.videoCell, for: indexPath) as! VideoGalleryTableViewCell
        let video = coreDataManager.practiceVideoFRC.object(at: indexPath)
        configure(cell, with: video)
        return cell
    }
    
    // MARK: UITableViewDataSource Helper Methods
    func configure(_ cell: VideoGalleryTableViewCell, with video: PracticeVideo) {
        cell.video = video
        cell.videoTitleLabel.text = video.title
        
        let url = URLBuilder.getDocumentsFilePathURL(for: video.filename)
        videoHelper?.getThumbnail(from: url) { image in
            cell.videoThumbnail.image = image
        }
    }
}

// MARK: - UITableViewDelegate
extension VideoGalleryTableManager: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // Workaround for an Apple bug where setting the cell selection style to None (see storyboard) causes
        // an inconsistent delay in this code being run.
        DispatchQueue.main.async {
            guard let selectedCell = tableView.cellForRow(at: indexPath) as? VideoGalleryTableViewCell else { return }
            guard let video = selectedCell.video else { return }
            
            if !tableView.isEditing {
                self.coordinator?.play(video, from: self.managedVC, self.videoHelper)
            } else {
                self.videoHelper?.uploadService.set(video: video)
                self.coordinator?.startEditingVideo(presentingVC: self.managedVC, videoHelper: self.videoHelper)
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
        
        // TODO: Add images to each of these
        
        let deleteAction = UIContextualAction(style: .destructive, title: Actions.delete) { [unowned self] (action, view, completionHandler) in
            var deleteSucceeded = true
            if let error = self.deleteVideo(in: tableView, at: indexPath) {
                self.managedVC.presentBasicAlert(title: UserErrors.deleteError, message: error.localizedDescription)
                deleteSucceeded = false
            }
            completionHandler(deleteSucceeded)
        }
        
        let editAction = UIContextualAction(style: .normal, title: Actions.edit) { [unowned self] (action, view, completionHandler) in
            let selectedCell = tableView.cellForRow(at: indexPath) as! VideoGalleryTableViewCell
            guard let video = selectedCell.video else { return }
            self.videoHelper?.uploadService.set(video: video)
            self.coordinator?.startEditingVideo(presentingVC: self.managedVC, videoHelper: self.videoHelper)
            tableView.reloadRows(at: [indexPath], with: .fade)
            completionHandler(true)
        }
        // rgb(22, 60, 94)
        editAction.backgroundColor = .lightGray
        
        let shareAction = UIContextualAction(style: .normal, title: Actions.share) { [unowned self] (action, view, completionHandler) in
            let selectedCell = tableView.cellForRow(at: indexPath) as! VideoGalleryTableViewCell
            guard let video = selectedCell.video else { return }
            self.coordinator?.share(video: video, from: self.managedVC)
            completionHandler(true)
        }
        shareAction.backgroundColor = .darkGray
        
        let moveAction = UIContextualAction(style: .normal, title: Actions.move) { [unowned self] (action, view, completionHandler) in
            let selectedCell = tableView.cellForRow(at: indexPath) as! VideoGalleryTableViewCell
            guard let video = selectedCell.video else { return }
            self.videoToMove = video
            
            guard let practiceSessions = self.coreDataManager.practiceSessionFRC.fetchedObjects else { return }
            
            self.practiceSessionPicker = PracticeSessionPickerView(tableView, self.coreDataManager)
            self.practiceSessionPicker.pickerManager.selectedVideoIndexPath = indexPath
            self.practiceSessionPicker.pickerManager.practiceSessions = practiceSessions
            self.practiceSessionPicker.pickerManager.oldPracticeSession = self.practiceSession
            self.practiceSessionPicker.pickerManager.videoToMove = video
            self.practiceSessionPicker!.configureView(in: self.managedVC.view)
            self.practiceSessionPicker!.show()
            
            completionHandler(true)
        }
        moveAction.backgroundColor = .black
        
        var configArray = [deleteAction, editAction, shareAction, moveAction]
        if let fetchedPracticeSessions = coreDataManager.practiceSessionFRC.fetchedObjects {
            let practiceSessionCount = fetchedPracticeSessions.count
            if practiceSessionCount == 1 {
                configArray = [deleteAction, editAction, shareAction]
            }
        }
        
        let config = UISwipeActionsConfiguration(actions: configArray)
        return config
    }
}

private extension VideoGalleryTableManager {
    func deleteVideo(in tableView: UITableView, at indexPath: IndexPath) -> NSError? {
        let videoToDelete = coreDataManager.practiceVideoFRC.object(at: indexPath)
        
        guard let practiceSession = practiceSession else {
            let noPracticeSessionError = NSError(domain: "VideoGallery", code: 0, userInfo: nil)
            noPracticeSessionError.setValue(UserErrors.noPracticeSession, forKey: NSLocalizedDescriptionKey)
            return noPracticeSessionError
        }
        
        if let error = VideoLocalStorageManager.delete(videoToDelete, from: practiceSession, coreDataManager) {
            return error
        }
        
        tableView.deleteRows(at: [indexPath], with: .fade)
        return nil
    }
}

// MARK: - NSFetchedResultsControllerDelegate
extension VideoGalleryTableManager: NSFetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch (type) {
        case .insert:
            if let indexPath = newIndexPath {
                tableView.insertRows(at: [indexPath], with: .fade)
            }
            break;
        case .delete:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            break;
        case .update:
            if let indexPath = indexPath {
                tableView.reloadRows(at: [indexPath], with: .fade)
            }
            break;
        default:
            print("\(#function): Unhandled case")
        }
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
}
