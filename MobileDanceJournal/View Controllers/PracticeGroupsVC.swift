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
    
    // TODO: TableManager class (and TableManager protocol, while we're at it?)
    weak var coordinator: MainCoordinator!
    var coreDataManager: CoreDataManager!
    var tableManager: PracticeGroupsTableManager!

    @IBOutlet weak var tableView: UITableView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableManager = configureTableManager(tableView, coreDataManager)
        setUpView()
    }
    
    private func setUpView() {
        tableView.tableFooterView = UIView()
    }
    
    private func configureTableManager(_ managedTableView: UITableView,_ coreDataManager: CoreDataManager) -> PracticeGroupsTableManager{
        let tableManager = PracticeGroupsTableManager(managedTableView, coreDataManager)
        tableManager.coordinator = coordinator
        managedTableView.dataSource = tableManager
        managedTableView.delegate = tableManager
        tableManager.managedVC = self
        return tableManager
    }
}
