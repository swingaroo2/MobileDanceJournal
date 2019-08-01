//
//  VideoGalleryVC+Extension.swift
//  MobileDanceJournal
//
//  Created by Zach Lockett-Streiff on 5/8/19.
//  Copyright © 2019 Swingaroo2. All rights reserved.
//

import Foundation
import UIKit
import CoreData

// MARK: - General Behavior
extension VideoGalleryVC {
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        videosTableView.setEditing(editing, animated: animated)
    }
    
    func prefetchVideos(for practiceSession: PracticeSession?) {
        guard let practiceSession = self.practiceSession else { return }
        let fetchedVideos = CoreDataManager.shared.fetchVideos(for: practiceSession)
        noContentLabel.isHidden = !fetchedVideos.isEmpty
    }
    
    func deleteVideo(in tableView: UITableView, at indexPath: IndexPath) -> NSError? {
        let videoToDelete = CoreDataManager.shared.practiceVideoFRC.object(at: indexPath)
        
        guard let practiceSession = self.practiceSession else {
            let noPracticeSessionError = NSError(domain: "VideoGallery", code: 0, userInfo: nil)
            noPracticeSessionError.setValue(UserErrors.noPracticeSession, forKey: NSLocalizedDescriptionKey)
            return noPracticeSessionError
        }
        
        if let error = VideoLocalStorageManager.delete(videoToDelete, from: practiceSession) {
            return error
        }
        
        tableView.reloadData()
        return nil
    }
}

// MARK: - IBActions
extension VideoGalleryVC {
    @IBAction func addVideoButtonPressed(_ sender: UIBarButtonItem) {
        AlertHelper.presentAddVideoActionSheet(from: self, and: sender)
    }
}

// MARK: - UITableViewDataSource
extension VideoGalleryVC: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let rightBarButtonItems = navigationItem.rightBarButtonItems else { return 0 }
        guard let editButton = rightBarButtonItems.last else { return 0 }
        
        guard let fetchedObjects = CoreDataManager.shared.practiceVideoFRC.fetchedObjects else {
            editButton.isEnabled = false
            return 0
        }
        
        let count = fetchedObjects.count
        
        noContentLabel.isHidden = (count > 0)
        
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifiers.videoCell, for: indexPath) as! VideoGalleryTableViewCell
        let video = CoreDataManager.shared.practiceVideoFRC.object(at: indexPath)
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
extension VideoGalleryVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // Workaround for an Apple bug where setting the cell selection style to None (see storyboard) causes
        // an inconsistent delay in this code being run.
        DispatchQueue.main.async {
            guard let selectedCell = tableView.cellForRow(at: indexPath) as? VideoGalleryTableViewCell else { return }
            guard let video = selectedCell.video else { return }
            
            if !tableView.isEditing {
                self.coordinator?.play(video: video, from: self)
            } else {
                self.videoHelper?.uploadService.set(video: video)
                self.coordinator?.startEditingVideo(galleryVC: self)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if let error = deleteVideo(in: tableView, at: indexPath) {
                presentBasicAlert(title: UserErrors.deleteError, message: error.localizedDescription)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        // TODO: Add images to each of these
        let deleteAction = UIContextualAction(style: .destructive, title: Actions.delete) { [unowned self] (action, view, completionHandler) in
            var deleteSucceeded = true
            if let error = self.deleteVideo(in: tableView, at: indexPath) {
                self.presentBasicAlert(title: UserErrors.deleteError, message: error.localizedDescription)
                deleteSucceeded = false
                
            }
            completionHandler(deleteSucceeded)
        }
        
        let editAction = UIContextualAction(style: .normal, title: Actions.edit) { [unowned self] (action, view, completionHandler) in
            let selectedCell = tableView.cellForRow(at: indexPath) as! VideoGalleryTableViewCell
            guard let video = selectedCell.video else { return }
            self.videoHelper?.uploadService.set(video: video)
            self.coordinator?.startEditingVideo(galleryVC: self)
            completionHandler(true)
        }
        // rgb(22, 60, 94)
        editAction.backgroundColor = .lightGray
        
        let shareAction = UIContextualAction(style: .normal, title: Actions.share) { [unowned self] (action, view, completionHandler) in
            let selectedCell = tableView.cellForRow(at: indexPath) as! VideoGalleryTableViewCell
            guard let video = selectedCell.video else { return }
            self.coordinator?.share(video: video, from: self)
            completionHandler(true)
        }
        shareAction.backgroundColor = .darkGray
        
        let moveAction = UIContextualAction(style: .normal, title: Actions.move) { [unowned self] (action, view, completionHandler) in
            let selectedCell = tableView.cellForRow(at: indexPath) as! VideoGalleryTableViewCell
            guard let video = selectedCell.video else { return }
            self.videoToMove = video
            
            guard let practiceSessions = CoreDataManager.shared.practiceSessionFRC.fetchedObjects else { return }
            
            self.practiceSessionPicker = PracticeSessionPickerView(practiceSessions: practiceSessions, delegate: self, dataSource: self)
            self.practiceSessionPicker!.oldPracticeSession = self.practiceSession
            self.practiceSessionPicker!.videoToMove = video
            self.practiceSessionPicker!.configureView(in: self.view)
            self.practiceSessionPicker!.show()
            
            completionHandler(true)
        }
        moveAction.backgroundColor = .black
        
        var configArray = [deleteAction, editAction, shareAction, moveAction]
        if let fetchedPracticeSessions = CoreDataManager.shared.practiceSessionFRC.fetchedObjects {
            let practiceSessionCount = fetchedPracticeSessions.count
            if practiceSessionCount == 1 {
                configArray = [deleteAction, editAction, shareAction]
            }
        }
        
        let config = UISwipeActionsConfiguration(actions: configArray)
        return config
    }
}

// TODO: Really should look into moving DataSources and Delegates out of the view controller
extension VideoGalleryVC: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        guard let practiceSessions = CoreDataManager.shared.practiceSessionFRC.fetchedObjects else { return 0 }
        let numberOfComponents = practiceSessions.count
        return numberOfComponents
    }
}

extension VideoGalleryVC: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let practiceSession = CoreDataManager.shared.practiceSessionFRC.object(at: IndexPath(row: row, section: component))
        return practiceSession.title
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        var label: UILabel
        
        if let view = view as? UILabel {
            label = view
        } else {
            label = UILabel()
        }
        
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont(name: "Menlo-Regular", size: 17)
        
        let practiceSession = practiceSessionPicker!.practiceSessions[row]
        label.text = practiceSession.title
        
        return label
    }
    
    @objc func doneButtonPressed() {
        guard let pickerContainer = practiceSessionPicker else { return }
        let selectedRow = pickerContainer.picker.selectedRow(inComponent: 0)
        let selected = pickerContainer.practiceSessions[selectedRow]
        guard let oldPracticeSession = pickerContainer.oldPracticeSession else { return }
        guard let videoToMove = pickerContainer.videoToMove else { return }
        
        CoreDataManager.shared.move(videoToMove, from: oldPracticeSession, to: selected)
        videosTableView.reloadData()
        pickerContainer.hide()
    }

}

// MARK: - UIImagePickerControllerDelegate
extension VideoGalleryVC: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let videoURL = info[.mediaURL] as? URL else {
            coordinator?.dismiss(picker) { [weak self] in
                self?.presentBasicAlert(title: VideoUploadErrors.generic, message: VideoUploadErrors.noURL)
            }
            return
        }
        videoHelper?.uploadService.url = videoURL
        coordinator?.startEditingVideo(galleryVC: self, videoPicker: picker)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        coordinator?.dismiss(picker) { print("\(#function)") }
    }
    
}

// TODO: Find a way to move this to coordinator
// MARK: - UINavigationControllerDelegate
extension VideoGalleryVC: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        viewController.navigationItem.title = VCConstants.chooseVideo
        print("\(#function)")
    }
}

// MARK: - NSFetchedResultsControllerDelegate
extension VideoGalleryVC: NSFetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch (type) {
        case .insert:
            if let indexPath = newIndexPath {
                videosTableView.insertRows(at: [indexPath], with: .fade)
            }
            break;
        case .delete:
            if let indexPath = indexPath {
                videosTableView.deleteRows(at: [indexPath], with: .fade)
            }
            break;
        case .update:
            if let indexPath = indexPath {
                videosTableView.reloadRows(at: [indexPath], with: .fade)
            }
            break;
        default:
            print("\(#function): Unhandled case")
        }
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        videosTableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        videosTableView.endUpdates()
    }
}

// MARK: - Storyboarded
extension VideoGalleryVC: Storyboarded {}
