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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // To keep the Uncategorized cell's practice log count up to date
        tableView.reloadData()
    }
    
    private func setUpView() {
        title = VCConstants.practiceGroupsVCTitle
        tableView.tableFooterView = UIView()
        navigationItem.leftBarButtonItem = editButtonItem
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addGroup))
    }
    
    @objc private func addGroup() {
        coordinator.startEditing(group: nil)
    }
    
    private func configureTableManager(_ managedTableView: UITableView,_ coreDataManager: CoreDataManager) -> PracticeGroupsTableManager{
        let tableManager = PracticeGroupsTableManager(managedTableView, coreDataManager)
        tableManager.coordinator = coordinator
        tableManager.managedVC = self
        return tableManager
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        tableView.setEditing(editing, animated: animated)
    }
}
