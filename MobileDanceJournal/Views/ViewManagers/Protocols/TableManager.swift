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

protocol TableManager: UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate {
    var managedTableView: UITableView { get }
    var managedVC: UIViewController { get }
    
    init(_ managedTableView: UITableView, managedVC: UIViewController)
}

protocol SelectionTrackingTableManager: TableManager {
    var selectedRow: Int { get set }
}

// MARK: - Optional functions
extension TableManager {
    func configureCell(_ cell: UITableViewCell,_ indexPath: IndexPath) {
        Log.trace("Adopting class must implement")
    }
}
