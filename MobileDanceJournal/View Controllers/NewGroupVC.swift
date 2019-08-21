//
//  NewGroupVC.swift
//  MobileDanceJournal
//
//  Created by Zach Lockett-Streiff on 8/20/19.
//  Copyright © 2019 Swingaroo2. All rights reserved.
//

import UIKit

class NewGroupVC: UIViewController, Storyboarded {
    
    weak var coordinator: MainCoordinator!
    var coreDataManager: CoreDataManager!
    var tableManager: PracticeLogTableManager!
    
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var groupNameTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableManager = configureTableManager(tableView, coreDataManager)
    }
    
    private func configureTableManager(_ managedTableView: UITableView,_ coreDataManager: CoreDataManager) -> PracticeLogTableManager{
        tableView.tableFooterView = UIView()
        let tableManager = PracticeLogTableManager(tableView, coreDataManager)
        tableManager.managedVC = self
        tableManager.coordinator = coordinator
        return tableManager
    }
    
    @IBAction func buttonPressed(_ sender: UIButton) {
        switch sender {
            case saveButton:
                print("Save")
                
                // Create new Group
                
                
                // Add any selected practice sessions to new Group
                let selectedPracticeSessions = tableManager.getSelectedPracticeSessions()
                break
            case cancelButton:
                coordinator.dismiss(self, completion: nil)
                break
            default:
                break
        }
    }
    
}
