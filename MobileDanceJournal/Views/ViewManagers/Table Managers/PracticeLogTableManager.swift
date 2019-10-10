//
//  PracticeLogTableManager.swift
//  MobileDanceJournal
//
//  Created by Zach Lockett-Streiff on 8/3/19.
//  Copyright © 2019 Swingaroo2. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class PracticeLogTableManager: NSObject, SelectionTrackingTableManager {
    
    var coreDataManager: CoreDataManager
    var managedTableView: UITableView
    var managedVC: UIViewController
    var selectedRow = -1
    
    var noContentLabel: UILabel?
    var groupPickerView: PracticeSessionPickerView!
    var coordinator: PracticeLogCoordinator!
    var practiceSessions: [PracticeSession]!
    var currentGroup: Group?
    
    required init(_ managedTableView: UITableView,_ coreDataManager: CoreDataManager, managedVC: UIViewController) {
        self.managedTableView = managedTableView
        self.coreDataManager = coreDataManager
        self.managedVC = managedVC
        super.init()
        self.managedTableView.delegate = self
        self.managedTableView.dataSource = self
    }
    
    func getSelectedPracticeSessions() -> [PracticeSession] {
        var selectedPracticeSessions = [PracticeSession]()
        guard let selectedIndexPaths = managedTableView.indexPathsForSelectedRows else { return selectedPracticeSessions }
        guard let practiceSessions = self.practiceSessions else { return selectedPracticeSessions }
        selectedPracticeSessions = selectedIndexPaths.map { practiceSessions[$0.row] }
        print(selectedPracticeSessions)
        return selectedPracticeSessions
    }
}

// MARK: UITableViewDataSource
extension PracticeLogTableManager: UITableViewDataSource {
    // TODO: Group cells by year
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let practiceSessions = coreDataManager.fetchPracticeSessions(in: currentGroup) else { return 0 }
        self.practiceSessions = practiceSessions
        let numRows = practiceSessions.count
        
        managedVC.navigationItem.leftBarButtonItem?.isEnabled = (numRows > 0)
        noContentLabel?.isHidden = (numRows > 0)
        return numRows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifiers.genericCell, for: indexPath)
        configureCell(cell, indexPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let practiceSession = coreDataManager.practiceSessionFRC.object(at: indexPath)
            coreDataManager.delete(practiceSession)
            
            // TODO: Is this necessary?
            let rowToDelete = indexPath.row
            if selectedRow == rowToDelete {
                coordinator?.clearDetailVC()
            }
        }
    }
}

// MARK: UITableViewDelegate
extension PracticeLogTableManager: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if !tableView.isEditing {
            selectedRow = indexPath.row
            
            guard let selectedCell = tableView.cellForRow(at: indexPath) else { return }
            selectedCell.isSelected = false
            selectedCell.textLabel?.highlightedTextColor = .darkText
            
            if tableView.allowsMultipleSelection {
                selectedCell.accessoryType = (selectedCell.accessoryType == .none) ? .checkmark : .none
            } else {
                let practiceSession = coreDataManager.practiceSessionFRC.object(at: indexPath)
                guard let coordinator = self.coordinator else { return }
                coordinator.showDetails(for: practiceSession)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        guard let selectedCell = tableView.cellForRow(at: indexPath) else { return }
        selectedCell.accessoryType = (selectedCell.accessoryType == .checkmark) ? .none : selectedCell.accessoryType
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        let editingStyle = tableView.allowsMultipleSelection ? UITableViewCell.EditingStyle.none : .delete
        return editingStyle
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {

        let deleteAction = UIContextualAction(style: .destructive, title: Actions.delete) { [unowned self] (action, view, completionHandler) in
            
            let deleteAlertAction: ((UIAlertAction) -> Void) = { action in
                let practiceSessionToDelete = self.coreDataManager.practiceSessionFRC.object(at: indexPath)
                self.coreDataManager.delete(practiceSessionToDelete)
                
                self.managedTableView.deleteRows(at: [indexPath], with: .fade)
                guard let fetchedPracticeLogs = self.coreDataManager.fetchPracticeSessions(in: self.currentGroup) else { return }
                self.noContentLabel?.isHidden = (fetchedPracticeLogs.count > 0)
                
                // TODO: Verify if this is necessary (for iPad, it might be)
                let rowToDelete = indexPath.row
                if self.selectedRow == rowToDelete {
                    self.coordinator?.clearDetailVC()
                }
                
                completionHandler(true)
            }
            
            let noAlertAction: ((UIAlertAction) -> Void) = { action in
                completionHandler(false)
            }
            
            self.managedVC.presentYesNoAlert(message: AlertConstants.confirmPracticeLogDelete, isDeleteAlert: true, yesAction: deleteAlertAction, noAction: noAlertAction)
            
        }
        
        let moveAction = UIContextualAction(style: .normal, title: Actions.move) { [unowned self] (action, view, completionHandler) in
            let practiceLogToMove = self.coreDataManager.practiceSessionFRC.object(at: indexPath)

            guard let groups = self.coreDataManager.groupFRC.fetchedObjects else {
                completionHandler(false)
                return
            }
            
            let groupPickerView = GroupPickerView(practiceLogToMove, practiceLogToMove.group, groups, self.coreDataManager, managedView: self.managedVC.view, self.coordinator)
            groupPickerView.show()
            completionHandler(true)
        }
        moveAction.backgroundColor = .black
        
        var swipeActions = [deleteAction, moveAction]
        
        if let fetchedGroups = coreDataManager.groupFRC.fetchedObjects {
            if fetchedGroups.count == 1 {
                swipeActions = [deleteAction]
            }
        }
        
        let swipeActionsConfig = UISwipeActionsConfiguration(actions: swipeActions)
        swipeActionsConfig.performsFirstActionWithFullSwipe = false
        return swipeActionsConfig
    }
}

private extension PracticeLogTableManager {
    private func configureCell(_ cell: UITableViewCell, _ indexPath: IndexPath) {
        guard let practiceSessions = coreDataManager.fetchPracticeSessions(in: currentGroup) else { return }
        
        let practiceSession = practiceSessions[indexPath.row]
        cell.textLabel?.text = practiceSession.title
        cell.textLabel?.highlightedTextColor = .darkText
        
        let videoCount = practiceSession.videos.count
        cell.detailTextLabel?.text = videoCount != 1 ? "\(videoCount) Videos" : "\(videoCount) Video"
        cell.detailTextLabel?.highlightedTextColor = .darkText
    }
}
