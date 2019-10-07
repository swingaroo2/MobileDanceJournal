//
//  TableManager.swift
//  MobileDanceJournal
//
//  Created by Zach Lockett-Streiff on 10/5/19.
//  Copyright © 2019 Swingaroo2. All rights reserved.
//

import Foundation
import UIKit
import CoreData

// TODO: Add search to table view (can even part of it be done here? That'd be groovy)
protocol TableManager: UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate {
    var managedTableView: UITableView { get }
    var coreDataManager: CoreDataManager { get }
    var managedVC: UIViewController { get }
    
    init(_ managedTableView: UITableView,_ coreDataManager: CoreDataManager, managedVC: UIViewController)
}

protocol SelectionTrackingTableManager: TableManager {
    var selectedRow: Int { get set }
}

// MARK: - Optional functions
extension TableManager {
    func configureCell(_ cell: UITableViewCell,_ indexPath: IndexPath) {
        // Adopting class must implement
    }
}