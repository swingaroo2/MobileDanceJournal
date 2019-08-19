//
//  PracticeLogVC.swift
//  MobileDanceJournal
//
//  Created by Zach Lockett-Streiff on 4/21/19.
//  Copyright © 2019 Swingaroo2. All rights reserved.
//

import UIKit

class PracticeLogVC: UIViewController, Storyboarded {
    
    weak var coordinator: MainCoordinator!
    var coreDataManager: CoreDataManager!
    var detailVC: PracticeNotepadVC?
    var tableManager: PracticeLogTableManager!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableManager = configureTableManager(tableView, coreDataManager)
        setUpView()
    }

    private func configureTableManager(_ managedTableView: UITableView,_ coreDataManager: CoreDataManager) -> PracticeLogTableManager{
        let tableManager = PracticeLogTableManager(managedTableView, coreDataManager)
        tableManager.coordinator = coordinator
        managedTableView.dataSource = tableManager
        managedTableView.delegate = tableManager
        tableManager.managedVC = self
        return tableManager
    }
    
    private func setUpView() {
        navigationItem.leftBarButtonItem = editButtonItem
        tableView.tableFooterView = UIView()
    }
    
    private func setUpDetailVC() {
        if let split = splitViewController {
            let controllers = split.viewControllers
            detailVC = (controllers[controllers.count-1] as! UINavigationController).topViewController as? PracticeNotepadVC
        }
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

    // TODO: Later, this will be replaced with a custom cell
    func configureCell(_ cell: UITableViewCell, _ indexPath: IndexPath) {
        let practiceSession = tableManager.practiceSessions[indexPath.row]
        cell.textLabel!.text = practiceSession.title
        cell.textLabel?.highlightedTextColor = .darkText
    }
}
