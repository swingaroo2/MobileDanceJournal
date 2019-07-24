//
//  PracticeLogVC.swift
//  MobileDanceJournal
//
//  Created by Zach Lockett-Streiff on 4/21/19.
//  Copyright © 2019 Swingaroo2. All rights reserved.
//

import UIKit

class PracticeLogVC: UITableViewController {
    
    var practiceSessions = [PracticeSession]()
    var selectedRow = -1
    weak var coordinator: MainCoordinator?
    var detailVC: PracticeNotepadVC?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
    }
    
    private func selectFirstCell() {
        let indexPath = IndexPath(row: 0, section: 0)
        tableView.selectRow(at: indexPath, animated: true, scrollPosition: .top)
        let practiceSession = CoreDataManager.shared.practiceSessionFRC.object(at: indexPath)
        coordinator?.showDetails(for: practiceSession)
    }
    
    private func setUpView() {
        CoreDataManager.shared.practiceSessionDelegate = self
        navigationItem.leftBarButtonItem = editButtonItem
        tableView.tableFooterView = UIView()
    }
    
    private func setUpDetailVC() {
        if let split = splitViewController {
            let controllers = split.viewControllers
            detailVC = (controllers[controllers.count-1] as! UINavigationController).topViewController as? PracticeNotepadVC
        }
    }
}
