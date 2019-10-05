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

// TODO: TableManager protocol?
class PracticeGroupsTableManager: NSObject {
    
    private let managedTableView: UITableView
    private let coreDataManager: CoreDataManager
    var managedVC: UIViewController!
    var coordinator: MainCoordinator!
    var groups: [Group]!
    
    init(_ managedTableView: UITableView,_ coreDataManager: CoreDataManager) {
        self.managedTableView = managedTableView
        self.coreDataManager = coreDataManager
        super.init()
        self.managedTableView.tableFooterView = UIView()
        self.managedTableView.delegate = self
        self.managedTableView.dataSource = self
        self.coreDataManager.practiceGroupsDelegate = self
        self.coreDataManager.practiceSessionDelegate = nil
    }
}

// MARK: - UITableViewDataSource
extension PracticeGroupsTableManager: UITableViewDataSource {
    // TODO: Group cells by month and year
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let fetchedGroups = coreDataManager.groupFRC.fetchedObjects else { return 1 }
        
        // +1 for Uncategorized cell
        groups = fetchedGroups
        return fetchedGroups.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifiers.genericCell, for: indexPath)
        let group = (indexPath.row >= groups.count) ? nil : coreDataManager.groupFRC.object(at: indexPath)
        
        configureCell(cell, group)
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        guard let fetchedGroups = coreDataManager.groupFRC.fetchedObjects else { return false }
        
        var canEdit = false
        
        if fetchedGroups.count == 0 {
            canEdit = false
        } else {
            canEdit = (indexPath.row < fetchedGroups.count)
        }
        
        return canEdit
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let selectedGroup = coreDataManager.groupFRC.object(at: indexPath)
            managedVC.presentYesNoAlert(message: AlertConstants.confirmDelete, isDeleteAlert: true, yesAction: { [unowned self] action in self.coreDataManager.delete(selectedGroup) })
        }
    }
}

// MARK: - UITableViewDelegate
extension PracticeGroupsTableManager: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let selectedCell = tableView.cellForRow(at: indexPath) else { return }
        selectedCell.isSelected = false
        guard let textLabel = selectedCell.textLabel else { return }
        
        if !tableView.isEditing {
            if textLabel.text == TextConstants.uncategorized {
                coordinator.showPracticeLog(group: nil)
            } else {
                let selectedGroup = coreDataManager.groupFRC.object(at: indexPath)
                coordinator.showPracticeLog(group: selectedGroup)
            }
        } else {
            if textLabel.text == TextConstants.uncategorized {
                return
            }
            
            managedVC.setEditing(false, animated: true)
            guard let fetchedObjects = coreDataManager.groupFRC.fetchedObjects else { return }
            if indexPath.row < fetchedObjects.count {
                let selectedGroup = coreDataManager.groupFRC.object(at: indexPath)
                coordinator.startEditing(group: selectedGroup)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        guard let selectedCell = tableView.cellForRow(at: indexPath) else { return .none }
        guard let textLabel = selectedCell.textLabel else { return .delete }
        
        if textLabel.text == TextConstants.uncategorized {
            return .none
        }
        
        return .delete
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: Actions.delete) { [unowned self] (action, view, completionHandler) in
            
            let deleteAlertAction: ((UIAlertAction) -> Void) = { action in
                let practiceGroupToDelete = self.coreDataManager.groupFRC.object(at: indexPath)
                print("Deleting group \(practiceGroupToDelete.name) at \(indexPath)")
                self.coreDataManager.delete(practiceGroupToDelete)
                completionHandler(true)
            }
            
            let noAlertAction: ((UIAlertAction) -> Void) = { action in
                completionHandler(false)
            }
            
            self.managedVC.presentYesNoAlert(message: AlertConstants.confirmDelete, isDeleteAlert: true, yesAction: deleteAlertAction, noAction: noAlertAction)
            
        }
        
        let swipeActionsConfig = UISwipeActionsConfiguration(actions: [deleteAction])
        swipeActionsConfig.performsFirstActionWithFullSwipe = false
        return swipeActionsConfig
    }
}

// MARK: - NSFetchedResultsControllerDelegate
extension PracticeGroupsTableManager: NSFetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch (type) {
        case .insert:
            print("INSERT: \(anObject)")
            if let indexPath = newIndexPath {
                managedTableView.insertRows(at: [indexPath], with: .fade)
                
                let numberOfRows = managedTableView.numberOfRows(inSection: 0)
                managedTableView.reloadRows(at: [IndexPath(row: numberOfRows - 1, section: 0)], with: .fade)
            }
        case .delete:
            print("DELETE: \(anObject)")
            if let indexPath = indexPath {
                managedTableView.deleteRows(at: [indexPath], with: .fade)
                
                let numberOfRows = managedTableView.numberOfRows(inSection: 0)
                managedTableView.reloadRows(at: [IndexPath(row: numberOfRows - 1, section: 0)], with: .fade)
            }
        case .update:
            print("UPDATE: \(anObject)")
            if let indexPath = indexPath {
                managedTableView.reloadRows(at: [indexPath], with: .fade)
            }
        default:
            print("\(#file).\(#function): Unhandled type: \(type)")
            break
        }
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        managedTableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        managedTableView.endUpdates()
    }
}

// MARK: - Private extensions
private extension PracticeGroupsTableManager {
    private func configureCell(_ cell: UITableViewCell,_ group: Group?) {
        cell.textLabel?.text = (group != nil) ? group!.name : TextConstants.uncategorized
        let isConfiguringUncategorizedCell = cell.textLabel?.text == TextConstants.uncategorized
        
        cell.detailTextLabel?.text = "0 Practice Logs"
        cell.detailTextLabel?.highlightedTextColor = .darkText
        
        if group != nil || isConfiguringUncategorizedCell {
            guard let practiceLogs = coreDataManager.fetchPracticeSessions(in: group) else { return }
            cell.detailTextLabel?.text = "\(practiceLogs.count) \(practiceLogs.count != 1 ? "Practice Logs" : "Practice Log")"
        }
    }
}
