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
    var tableManager: PracticeLogTableManager!
    var currentGroup: Group?
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableManager = configureTableManager(tableView, coreDataManager)
        setUpView()
    }

    private func configureTableManager(_ managedTableView: UITableView,_ coreDataManager: CoreDataManager) -> PracticeLogTableManager {
        let tableManager = PracticeLogTableManager(managedTableView, coreDataManager)
        tableManager.coordinator = coordinator
        tableManager.managedVC = self
        tableManager.currentGroup = currentGroup
        return tableManager
    }
    
    private func setUpView() {
        navigationItem.leftItemsSupplementBackButton = true
        navigationItem.leftBarButtonItem = editButtonItem
        tableView.tableFooterView = UIView()
    }
    
    @IBAction func createNewPracticeSession(_ sender: UIBarButtonItem) {
        tableManager.selectedRow = 0
        coordinator?.startEditingNewPracticeSession()
    }

    override internal func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        guard let _ = splitViewController?.detailVC else {
            print(InternalErrors.failedToGetReferenceToDetailVC)
            return
        }
    }
}
