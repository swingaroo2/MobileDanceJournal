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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableManager = configureTableManager(tableView, coreDataManager)
        setUpView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    private func configureTableManager(_ managedTableView: UITableView,_ coreDataManager: CoreDataManager) -> PracticeLogTableManager {
        let practiceLogCount = coreDataManager.fetchPracticeSessions(in: currentGroup)?.count ?? 0
        
        let tableManager = PracticeLogTableManager(managedTableView, coreDataManager, practiceLogCount, managedVC: self)
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
        tableManager.selectedRow = 0
        coordinator?.startEditingNewPracticeSession()
    }

    override internal func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        tableManager.managedTableView.setEditing(editing, animated: animated)
    }
}
