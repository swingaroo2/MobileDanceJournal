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

class PracticeGroupsTableManager: NSObject {
    
    private let managedTableView: UITableView
    private let coreDataManager: CoreDataManager
    var managedVC: UIViewController!
    var coordinator: MainCoordinator!
    var practiceSessions: [PracticeSession]!
    var selectedRow = -1
    
    init(_ managedTableView: UITableView,_ coreDataManager: CoreDataManager) {
        self.managedTableView = managedTableView
        self.coreDataManager = coreDataManager
        super.init()
        self.coreDataManager.practiceGroupsDelegate = self
    }
}

extension PracticeGroupsTableManager: UITableViewDataSource {
    // TODO: Group cells by month and year
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(frame: .zero)
        configureCell(cell, indexPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        guard let selectedCell = tableView.cellForRow(at: indexPath) else { return false }
        guard let textLabel = selectedCell.textLabel else { return false }
        
        let canEdit = textLabel.text != TextConstants.uncategorized
        
        return canEdit
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
    }
}

extension PracticeGroupsTableManager: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let selectedCell = tableView.cellForRow(at: indexPath) else { return }
        selectedCell.isSelected = false
        
        guard let textLabel = selectedCell.textLabel else { return }
        if textLabel.text == TextConstants.uncategorized {
            coordinator.showPracticeLog()
            
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
}

// MARK: - NSFetchedResultsControllerDelegate
extension PracticeGroupsTableManager: NSFetchedResultsControllerDelegate {
    
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
            print("\(#file).\(#function): Unhandled case")
        }
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        managedTableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        managedTableView.endUpdates()
    }
}

private extension PracticeGroupsTableManager {
    // TODO: Later, this will be replaced with a custom cell
    private func configureCell(_ cell: UITableViewCell, _ indexPath: IndexPath) {
        cell.textLabel?.text = TextConstants.uncategorized
    }
    
}
