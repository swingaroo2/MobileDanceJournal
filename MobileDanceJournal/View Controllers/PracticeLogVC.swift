//
//  PracticeLogVC.swift
//  MobileDanceJournal
//
//  Created by Zach Lockett-Streiff on 4/21/19.
//  Copyright © 2019 Swingaroo2. All rights reserved.
//

import UIKit

class PracticeLogVC: UIViewController, Storyboarded {
    
    weak var coordinator: PracticeLogCoordinator!
    var coreDataManager: CoreDataManager!
    var tableManager: SelectionTrackingTableManager!
    var currentGroup: Group?
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noContentLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableManager = configureTableManager(tableView, coreDataManager)
        setUpView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addNotificationListener()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        let backButtonPressed = self.isMovingFromParent
        
        if backButtonPressed {
            removeNotificationListener()
        }
    }
    
    // MARK: - Notifications
    func addNotificationListener() {
        NotificationCenter.default.addObserver(self, selector: #selector(PracticeLogVC.practiceLogUpdated), name: .practiceLogUpdated, object: nil)
    }
    
    func removeNotificationListener() {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func practiceLogUpdated(notification: Notification) {
        let indexPathToUpdate = IndexPath(row: tableManager.selectedRow, section: 0)
        tableManager.managedTableView.reloadRows(at: [indexPathToUpdate], with: .fade)
    }
    
    private func configureTableManager(_ managedTableView: UITableView,_ coreDataManager: CoreDataManager) -> PracticeLogTableManager {
        let tableManager = PracticeLogTableManager(managedTableView, coreDataManager, managedVC: self)
        tableManager.noContentLabel = noContentLabel
        tableManager.coordinator = coordinator
        tableManager.currentGroup = currentGroup
        return tableManager
    }
    
    private func setUpView() {
        navigationItem.leftItemsSupplementBackButton = true
        navigationItem.leftBarButtonItem = editButtonItem
        tableManager.managedTableView.tableFooterView = UIView()
    }
    
    @IBAction func createNewPracticeSession(_ sender: UIBarButtonItem) {
        let newIndexPath = IndexPath(row: 0, section: 0)
        tableManager.selectedRow = 0
        coordinator?.startEditingNewPracticeSession()
        tableManager.managedTableView.insertRows(at: [newIndexPath], with: .fade)
    }

    override internal func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        tableManager.managedTableView.setEditing(editing, animated: animated)
    }
}
