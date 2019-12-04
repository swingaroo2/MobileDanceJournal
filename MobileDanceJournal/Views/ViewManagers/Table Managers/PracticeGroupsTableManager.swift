//
//  PracticeGroupsTableManager.swift
//  MobileDanceJournal
//
//  Created by Zach Lockett-Streiff on 8/19/19.
//  Copyright © 2019 Swingaroo2. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class PracticeGroupsTableManager: NSObject, TableManager {
    
    var managedTableView: UITableView
    var managedVC: UIViewController
    
    var coordinator: MainCoordinator!
    var groups: [Group]!
    
    required init(_ managedTableView: UITableView, managedVC: UIViewController) {
        Log.trace()
        self.managedTableView = managedTableView
        self.managedVC = managedVC
        super.init()
        self.managedTableView.tableFooterView = UIView()
        self.managedTableView.delegate = self
        self.managedTableView.dataSource = self
        Model.coreData.practiceGroupsDelegate = self
    }
}

// MARK: - UITableViewDataSource
extension PracticeGroupsTableManager {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let fetchedGroups = Model.coreData.groupFRC.fetchedObjects else {
            Log.error("Failed to fetch groups")
            return 1
        }
        
        // +1 for Uncategorized cell
        groups = fetchedGroups
        let numRows = fetchedGroups.count + 1
        Log.trace("\(numRows) \(numRows != 1 ? "rows" : "row") in the group table")
        return numRows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifiers.genericCell, for: indexPath)
        configureCell(cell, indexPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        guard let fetchedGroups = Model.coreData.groupFRC.fetchedObjects else {
            Log.error("Failed to fetch groups")
            return false
        }
        
        var canEdit = false
        
        if fetchedGroups.isEmpty {
            canEdit = false
        } else {
            canEdit = (indexPath.row < fetchedGroups.count)
        }
        
        return canEdit
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let selectedGroup = Model.coreData.groupFRC.object(at: indexPath)
            managedVC.presentYesNoAlert(message: AlertConstants.confirmGroupDelete, isDeleteAlert: true, yesAction: { action in Model.coreData.delete(selectedGroup) })
        }
    }
}

// MARK: - UITableViewDelegate
extension PracticeGroupsTableManager {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        Log.trace()
        guard let selectedCell = tableView.cellForRow(at: indexPath) else {
            Log.error("Failed to get cell for row at Index Path: \(indexPath)")
            return
        }
        selectedCell.isSelected = false
        guard let textLabel = selectedCell.textLabel else {
            Log.critical("Failed to get reference to the selected cell's text label")
            return
        }
        
        if !tableView.isEditing {
            if textLabel.text == TextConstants.uncategorized {
                coordinator.showPracticeLog(group: nil)
            } else {
                let selectedGroup = Model.coreData.groupFRC.object(at: indexPath)
                coordinator.showPracticeLog(group: selectedGroup)
            }
        } else {
            if textLabel.text == TextConstants.uncategorized { return }
            
            managedVC.setEditing(false, animated: true)
            guard let fetchedObjects = Model.coreData.groupFRC.fetchedObjects else {
                Log.error("Failed to fetch groups")
                return
            }
            if indexPath.row < fetchedObjects.count {
                let selectedGroup = Model.coreData.groupFRC.object(at: indexPath)
                coordinator.startEditing(group: selectedGroup)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        guard let selectedCell = tableView.cellForRow(at: indexPath) else {
            Log.error("Failed to get cell for row at Index Path: \(indexPath)")
            return .none
        }
        guard let textLabel = selectedCell.textLabel else {
            Log.critical("Failed to get reference to the selected cell's text label")
            return .delete
        }
        
        if textLabel.text == TextConstants.uncategorized {
            return .none
        }
        
        return .delete
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        Log.trace()
        let deleteAction = UIContextualAction(style: .destructive, title: Actions.delete) { [unowned self] (action, view, completionHandler) in
            
            let deleteAlertAction: ((UIAlertAction) -> Void) = { action in
                let practiceGroupToDelete = Model.coreData.groupFRC.object(at: indexPath)
                Log.trace("Deleting group \(practiceGroupToDelete.name) at \(indexPath)")
                Model.coreData.delete(practiceGroupToDelete)
                completionHandler(true)
            }
            
            let noAlertAction: ((UIAlertAction) -> Void) = { action in
                completionHandler(false)
            }
            
            self.managedVC.presentYesNoAlert(message: AlertConstants.confirmGroupDelete, isDeleteAlert: true, yesAction: deleteAlertAction, noAction: noAlertAction)
            
        }
        
        let swipeActionsConfig = UISwipeActionsConfiguration(actions: [deleteAction])
        swipeActionsConfig.performsFirstActionWithFullSwipe = false
        return swipeActionsConfig
    }
}

// MARK: - NSFetchedResultsControllerDelegate
extension PracticeGroupsTableManager {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        Log.trace()
        switch (type) {
        case .insert:
            Log.trace("INSERT: \(anObject)")
            if let indexPath = newIndexPath {
                managedTableView.insertRows(at: [indexPath], with: .fade)
                
                let numberOfRows = managedTableView.numberOfRows(inSection: 0)
                managedTableView.reloadRows(at: [IndexPath(row: numberOfRows - 1, section: 0)], with: .fade)
            }
        case .delete:
            Log.trace("DELETE: \(anObject)")
            if let indexPath = indexPath {
                managedTableView.deleteRows(at: [indexPath], with: .fade)
                
                let numberOfRows = managedTableView.numberOfRows(inSection: 0)
                managedTableView.reloadRows(at: [IndexPath(row: numberOfRows - 1, section: 0)], with: .fade)
            }
        case .update:
            Log.trace("UPDATE: \(anObject)")
            if let indexPath = indexPath {
                managedTableView.reloadRows(at: [indexPath], with: .fade)
            }
        default:
            Log.error("\(#file).\(#function): Unhandled type: \(type)")
            break
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

// MARK: - Private Methods
private extension PracticeGroupsTableManager {
    func configureCell(_ cell: UITableViewCell, _ indexPath: IndexPath) {
        let group = (indexPath.row >= groups.count) ? nil : Model.coreData.groupFRC.object(at: indexPath)
        cell.textLabel?.text = (group != nil) ? group!.name : TextConstants.uncategorized
        let isConfiguringUncategorizedCell = cell.textLabel?.text == TextConstants.uncategorized
        
        cell.detailTextLabel?.text = "0 Practice Logs"
        cell.detailTextLabel?.highlightedTextColor = .darkText
        
        if group != nil || isConfiguringUncategorizedCell {
            guard let practiceLogs = Model.coreData.fetchPracticeSessions(in: group) else {
                Log.error("Failed to fetch Practice Logs")
                return
            }
            cell.detailTextLabel?.text = "\(practiceLogs.count) \(practiceLogs.count != 1 ? "Practice Logs" : "Practice Log")"
        }
    }
}
