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
    
    var managedTableView: UITableView
    var managedVC: UIViewController
    var selectedRow = -1
    
    var noContentLabel: UILabel?
    var groupPickerView: GroupPickerView!
    var coordinator: PracticeLogCoordinator!
    var practiceSessions: [PracticeSession]!
    var currentGroup: Group?
    
    required init(_ managedTableView: UITableView, managedVC: UIViewController) {
        Log.trace()
        self.managedTableView = managedTableView
        self.managedVC = managedVC
        super.init()
        self.managedTableView.delegate = self
        self.managedTableView.dataSource = self
    }
    
    func getSelectedPracticeSessions() -> [PracticeSession] {
        Log.trace()
        var selectedPracticeSessions = [PracticeSession]()
        guard let selectedIndexPaths = managedTableView.indexPathsForSelectedRows else {
            Log.error("Failed to get Index Paths for selected rows")
            return selectedPracticeSessions
        }
        guard let practiceSessions = self.practiceSessions else {
            Log.error("Failed to get reference to Practice Logs")
            return selectedPracticeSessions
        }
        selectedPracticeSessions = selectedIndexPaths.map { practiceSessions[$0.row] }
        Log.trace("Selected practice logs: \(selectedPracticeSessions)")
        return selectedPracticeSessions
    }
}

// MARK: - UITableViewDataSource
extension PracticeLogTableManager: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let practiceSessions = Model.coreData.fetchPracticeSessions(in: currentGroup) else {
            Log.error("Failed to fetch Practice Logs from group: \(currentGroup?.name ?? "NIL")")
            return 0
        }
        self.practiceSessions = practiceSessions
        let numRows = practiceSessions.count
        
        managedVC.navigationItem.leftBarButtonItem?.isEnabled = numRows > 0
        noContentLabel?.isHidden = numRows > 0
        Log.trace("\(numRows) \(numRows != 1 ? "rows" : "row") in the Practice Log table")
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
            let practiceSession = Model.coreData.practiceSessionFRC.object(at: indexPath)
            Model.coreData.delete(practiceSession)
            
            let rowToDelete = indexPath.row
            if selectedRow == rowToDelete {
                coordinator?.clearDetailVC()
            }
        }
    }
}

// MARK: - UITableViewDelegate
extension PracticeLogTableManager: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        Log.trace()
        if !tableView.isEditing {
            selectedRow = indexPath.row
            
            guard let selectedCell = tableView.cellForRow(at: indexPath) else {
                Log.error("Failed to get cell for row at Index Path: \(indexPath)")
                return
            }
            selectedCell.isSelected = false
            selectedCell.textLabel?.highlightedTextColor = .darkText
            
            if tableView.allowsMultipleSelection {
                selectedCell.accessoryType = (selectedCell.accessoryType == .none) ? .checkmark : .none
            } else {
                let practiceSession = Model.coreData.practiceSessionFRC.object(at: indexPath)
                guard let coordinator = self.coordinator else {
                    Log.error("Failed to get reference to Practice Log Coordinator")
                    return
                }
                coordinator.showDetails(for: practiceSession)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        Log.trace()
        guard let selectedCell = tableView.cellForRow(at: indexPath) else {
            Log.error("Failed to get cell for row at Index Path: \(indexPath)")
            return
        }
        selectedCell.accessoryType = (selectedCell.accessoryType == .checkmark) ? .none : selectedCell.accessoryType
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        let editingStyle = tableView.allowsMultipleSelection ? UITableViewCell.EditingStyle.none : .delete
        return editingStyle
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        Log.trace()
        let deleteAction = UIContextualAction(style: .destructive, title: Actions.delete) { [unowned self] (action, view, completionHandler) in
            
            let deleteAlertAction: ((UIAlertAction) -> Void) = { action in
                let practiceSessionToDelete = Model.coreData.practiceSessionFRC.object(at: indexPath)
                Model.coreData.delete(practiceSessionToDelete)
                
                self.managedTableView.deleteRows(at: [indexPath], with: .fade)
                guard let fetchedPracticeLogs = Model.coreData.fetchPracticeSessions(in: self.currentGroup) else {
                    Log.error("Failed to fetch Practice Logs in group: \(self.currentGroup?.name ?? "NIL")")
                    return
                }
                self.noContentLabel?.isHidden = fetchedPracticeLogs.count > 0
                
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
            let practiceLogToMove = Model.coreData.practiceSessionFRC.object(at: indexPath)

            guard let groups = Model.coreData.groupFRC.fetchedObjects else {
                Log.error("Failed to fetch groups")
                completionHandler(false)
                return
            }
            
            let groupPickerView = GroupPickerView(practiceLogToMove, practiceLogToMove.group, groups, managedView: self.managedVC.view, self.coordinator)
            groupPickerView.show()
            completionHandler(true)
        }
        moveAction.backgroundColor = .black
        
        var swipeActions = [deleteAction, moveAction]
        
        if let fetchedGroups = Model.coreData.groupFRC.fetchedObjects {
            if fetchedGroups.isEmpty {
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
        guard let practiceSessions = Model.coreData.fetchPracticeSessions(in: currentGroup) else {
            Log.error("Failed to fetch Practice Logs in group: \(currentGroup?.name ?? "NIL")")
            return
        }
        
        let practiceSession = practiceSessions[indexPath.row]
        cell.textLabel?.text = practiceSession.title
        cell.textLabel?.highlightedTextColor = .darkText
        
        let videoCount = practiceSession.videos.count
        cell.detailTextLabel?.text = videoCount != 1 ? "\(videoCount) Videos" : "\(videoCount) Video"
        cell.detailTextLabel?.highlightedTextColor = .darkText
    }
}
