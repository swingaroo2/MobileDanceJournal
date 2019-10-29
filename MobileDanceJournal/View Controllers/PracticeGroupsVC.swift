//
//  PracticeGroupsVC.swift
//  MobileDanceJournal
//
//  Created by Zach Lockett-Streiff on 8/19/19.
//  Copyright © 2019 Swingaroo2. All rights reserved.
//

import Foundation
import UIKit

class PracticeGroupsVC: UIViewController, Storyboarded {
    
    weak var coordinator: MainCoordinator!
    var coreDataManager: CoreDataManager!
    var tableManager: TableManager!

    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        tableManager = configureTableManager(tableView, coreDataManager)
        setUpView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // To keep the Uncategorized cell's practice log count up to date
        tableManager.managedTableView.reloadData()
    }
    
    override internal func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        tableManager.managedTableView.setEditing(editing, animated: animated)
    }
}

// MARK: - Private Methods
private extension PracticeGroupsVC {
    func setUpView() {
        title = VCConstants.practiceGroupsVCTitle
        navigationItem.leftBarButtonItem = editButtonItem
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addGroup))
    }
    
    @objc func addGroup() {
        coordinator.startEditing(group: nil)
    }
    
    func configureTableManager(_ managedTableView: UITableView,_ coreDataManager: CoreDataManager) -> PracticeGroupsTableManager {
        let tableManager = PracticeGroupsTableManager(managedTableView, coreDataManager, managedVC: self)
        tableManager.coordinator = coordinator
        return tableManager
    }
}
