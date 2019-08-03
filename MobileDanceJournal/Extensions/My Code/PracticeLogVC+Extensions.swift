 //
 //  PracticeLogVC+Extension.swift
 //  MobileDanceJournal
 //
 //  Created by Zach Lockett-Streiff on 4/24/19.
 //  Copyright © 2019 Swingaroo2. All rights reserved.
 //
 
 import UIKit
 import CoreData
 
 // MARK: - UITableViewDataSource
 extension PracticeLogVC {
    
    // TODO: Group cells by month and year
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let practiceSessions = coreDataManager.practiceSessionFRC.fetchedObjects else { return 0 }
        self.practiceSessions = practiceSessions
        navigationItem.leftBarButtonItem?.isEnabled = practiceSessions.count > 0
        return practiceSessions.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifiers.genericCell, for: indexPath)
        configureCell(cell, indexPath)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
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
    
    // TODO: Later, this will be replaced with a custom cell
    private func configureCell(_ cell: UITableViewCell, _ indexPath: IndexPath) {
        let practiceSession = practiceSessions[indexPath.row]
        cell.textLabel!.text = practiceSession.title
        cell.textLabel?.highlightedTextColor = .darkText
    }
 }
 
 // MARK: - UITableViewDelegate
 extension PracticeLogVC {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if !tableView.isEditing {
            selectedRow = indexPath.row
            let practiceSession = coreDataManager.practiceSessionFRC.object(at: indexPath)
            let selectedCell = tableView.cellForRow(at: indexPath)
            
            guard let coordinator = self.coordinator else { return }
            if !coordinator.rootVC.isDisplayingBothVCs() {
                selectedCell?.isSelected = false
            }
            
            selectedCell?.textLabel?.highlightedTextColor = .darkText
            coordinator.showDetails(for: practiceSession)
        }
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        guard let _ = splitViewController?.detailVC else {
            print(InternalErrors.failedToGetReferenceToDetailVC)
            return
        }
    }
 }
 
 // MARK: - NSFetchedResultsControllerDelegate
 extension PracticeLogVC: NSFetchedResultsControllerDelegate {
    
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
 
 // MARK: IBActions
 extension PracticeLogVC {
    @IBAction func createNewPracticeSession(_ sender: UIBarButtonItem) {
        selectedRow = 0
        coordinator?.startEditingNewPracticeSession()
    }
 }
 
 // MARK: - Storyboarded
 extension PracticeLogVC: Storyboarded {}
