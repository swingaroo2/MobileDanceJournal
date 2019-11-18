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
    var tableManager: TableManager!

    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        Log.trace()
        tableManager = configureTableManager(tableView)
        setUpView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Log.trace()
        // To keep the Uncategorized cell's practice log count up to date
        tableManager.managedTableView.reloadData()
    }
    
    override internal func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        Log.trace()
        tableManager.managedTableView.setEditing(editing, animated: animated)
    }
}

// MARK: - Private Methods
private extension PracticeGroupsVC {
    func setUpView() {
        Log.trace()
        title = VCConstants.practiceGroupsVCTitle
        navigationItem.leftBarButtonItem = editButtonItem
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addGroup))
    }
    
    @objc func addGroup() {
        Log.trace()
        coordinator.startEditing(group: nil)
    }
    
    func configureTableManager(_ managedTableView: UITableView) -> PracticeGroupsTableManager {
        Log.trace()
        let tableManager = PracticeGroupsTableManager(managedTableView, managedVC: self)
        tableManager.coordinator = coordinator
        return tableManager
    }
}
