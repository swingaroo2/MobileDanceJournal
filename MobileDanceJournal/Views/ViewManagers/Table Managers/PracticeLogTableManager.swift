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

class PracticeLogTableManager: NSObject {
    
    private let managedTableView: UITableView
    private let coreDataManager: CoreDataManager
    var groupPickerView: PracticeSessionPickerView!
    var managedVC: UIViewController!
    var practiceSessions: [PracticeSession]!
    var coordinator: PracticeLogCoordinator!
    var currentGroup: Group?
    var selectedRow = -1
    var originalPracticeLogCount = 0
    
    init(_ managedTableView: UITableView,_ coreDataManager: CoreDataManager) {
        self.managedTableView = managedTableView
        self.coreDataManager = coreDataManager
        super.init()
        self.managedTableView.delegate = self
        self.managedTableView.dataSource = self
        self.coreDataManager.practiceSessionDelegate = self
    }
    
    init(_ managedTableView: UITableView,_ coreDataManager: CoreDataManager,_ originalPracticeLogCount: Int) {
        self.managedTableView = managedTableView
        self.coreDataManager = coreDataManager
        self.originalPracticeLogCount = originalPracticeLogCount
        super.init()
        self.managedTableView.delegate = self
        self.managedTableView.dataSource = self
        self.coreDataManager.practiceSessionDelegate = self
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
        managedVC.navigationItem.leftBarButtonItem?.isEnabled = practiceSessions.count > 0
        print("\(practiceSessions.count) Practice Session(s)")
        return practiceSessions.count
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
            coreDataManager.save()
            
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
            let practiceSessionToDelete = self.coreDataManager.practiceSessionFRC.object(at: indexPath)
            self.coreDataManager.delete(practiceSessionToDelete)
            
            guard self.currentGroup != nil else {
                completionHandler(true)
                return
            }
            self.managedTableView.deleteRows(at: [indexPath], with: .fade)
            self.originalPracticeLogCount -= 1
            
            completionHandler(true)
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

// MARK: - NSFetchedResultsControllerDelegate
extension PracticeLogTableManager: NSFetchedResultsControllerDelegate {
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch (type) {
        case .insert:
            print("INSERT: \(anObject)")
            if let indexPath = newIndexPath {
                managedTableView.insertRows(at: [indexPath], with: .fade)
                originalPracticeLogCount += 1
            }
            break;
        case .delete:
            print("DELETE: \(anObject)")
            if let indexPath = indexPath {
                managedTableView.deleteRows(at: [indexPath], with: .fade)
                originalPracticeLogCount -= 1
            }
            break;
        case .update:
            print("UPDATE: \(anObject)")
            if let indexPath = indexPath, let cell = managedTableView.cellForRow(at: indexPath) {
                guard let practiceLogs = coreDataManager.fetchPracticeSessions(in: currentGroup) else { return }
                if originalPracticeLogCount > practiceLogs.count {
                    managedTableView.deleteRows(at: [indexPath], with: .fade)
                    originalPracticeLogCount -= 1
                } else if originalPracticeLogCount == practiceLogs.count {
                    configureCell(cell, indexPath)
                } else {
                    managedTableView.insertRows(at: [indexPath], with: .fade)
                    originalPracticeLogCount += 1
                }
            }
        case .move:
            print("MOVE: \(anObject)")
            if let indexPath = indexPath, let newIndexPath = newIndexPath {
                managedTableView.deleteRows(at: [indexPath], with: .fade)
                managedTableView.insertRows(at: [newIndexPath], with: .fade)
            }
            break;
        default:
            print("\(#file).\(#function): Unhandled type \(type)")
        }
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        managedTableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
         managedTableView.endUpdates()
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
