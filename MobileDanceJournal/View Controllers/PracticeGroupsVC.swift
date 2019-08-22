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
    var tableManager: PracticeGroupsTableManager!

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableManager = configureTableManager(tableView, coreDataManager)
        setUpView()
    }
    
    private func setUpView() {
        title = VCConstants.practiceGroupsVCTitle
        tableView.tableFooterView = UIView()
        navigationItem.leftBarButtonItem = editButtonItem
        navigationItem.rightBarButtonItems = [UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addGroup))]
    }
    
    @objc private func addGroup() {
        coordinator.createNewGroup()
    }
    
    private func configureTableManager(_ managedTableView: UITableView,_ coreDataManager: CoreDataManager) -> PracticeGroupsTableManager{
        let tableManager = PracticeGroupsTableManager(managedTableView, coreDataManager)
        tableManager.coordinator = coordinator
        managedTableView.dataSource = tableManager
        managedTableView.delegate = tableManager
        tableManager.managedVC = self
        return tableManager
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        tableView.setEditing(editing, animated: animated)
    }
}
