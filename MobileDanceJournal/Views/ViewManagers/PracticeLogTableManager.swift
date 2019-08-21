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
    var managedVC: UIViewController!
    var coordinator: MainCoordinator!
    var practiceSessions: [PracticeSession]!
    var currentGroup: Group?
    var selectedRow = -1
    
    init(_ managedTableView: UITableView,_ coreDataManager: CoreDataManager) {
        self.managedTableView = managedTableView
        self.coreDataManager = coreDataManager
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
    // TODO: Group cells by month and year
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let practiceSessions = coreDataManager.fetchPracticeSessions(in: currentGroup) else { return 0 }
        self.practiceSessions = practiceSessions
        managedVC.navigationItem.leftBarButtonItem?.isEnabled = practiceSessions.count > 0
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
            let practiceSession = coreDataManager.practiceSessionFRC.object(at: indexPath)
            
            guard let coordinator = self.coordinator else { return }
            if !coordinator.rootVC.isDisplayingBothVCs() {
                selectedCell.isSelected = false
            }
            
            selectedCell.textLabel?.highlightedTextColor = .darkText
            
            if tableView.allowsMultipleSelection {
                selectedCell.accessoryType = .checkmark
            } else {
                selectedCell.isSelected = false
            }
            
            coordinator.showDetails(for: practiceSession)
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
}

// MARK: - NSFetchedResultsControllerDelegate
extension PracticeLogTableManager: NSFetchedResultsControllerDelegate {
    
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
            print("\(#function): Unhandled case")
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
    // TODO: Later, this will be replaced with a custom cell
    private func configureCell(_ cell: UITableViewCell, _ indexPath: IndexPath) {
        let practiceSession = practiceSessions[indexPath.row]
        cell.textLabel!.text = practiceSession.title
        cell.textLabel?.highlightedTextColor = .darkText
    }

}
