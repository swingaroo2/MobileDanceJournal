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
    var tableManager: PracticeLogTableManager!
    var editingGroup: Group?
    
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var groupNameTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var ungroupedPracticeLogsLabel: UILabel!
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        Log.trace()
        tableManager = configureTableManager(tableView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Log.trace()
        setUpView(with: editingGroup)
    }
}

// MARK: - UITextFieldDelegate
extension NewGroupVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        Log.trace()
        textField.resignFirstResponder()
        return true
    }
}

// MARK: - Private Methods
private extension NewGroupVC {
    @IBAction func buttonPressed(_ sender: UIButton) {
        Log.trace()
        switch sender {
        case saveButton:
            let selectedPracticeSessions = tableManager.getSelectedPracticeSessions()
            
            if let group = editingGroup {
                Model.coreData.update(group: group, name: groupNameTextField.text!, practiceSessions: selectedPracticeSessions)
            } else {
                Model.coreData.createAndSaveNewGroup(name: groupNameTextField.text!, practiceSessions: selectedPracticeSessions)
            }
            break
        case cancelButton:
            break
        default:
            break
        }
        
        coordinator.dismiss(self, completion: nil)
    }
    
    func setUpView(with group: Group?) {
        Log.trace("Setting up view for group: \(group?.name ?? "NIL")")
        groupNameTextField.delegate = self
        groupNameTextField.text = editingGroup?.name
        guard let text = groupNameTextField.text else {
            Log.critical("Failed to get reference to group name Text Field")
            return
        }
        saveButton.isEnabled = !text.isEmpty
        groupNameTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        guard let ungroupedPracticeSessions = Model.coreData.fetchPracticeSessions(in: nil) else {
            Log.error("Failed to fetch ungrouped Practice Logs")
            return
        }
        ungroupedPracticeLogsLabel.isHidden = (ungroupedPracticeSessions.count == 0)
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        guard let text = textField.text else {
            Log.critical("Failed to get reference to group title Text Field")
            return
        }
        saveButton.isEnabled = !text.isEmpty
    }
    
    func configureTableManager(_ managedTableView: UITableView) -> PracticeLogTableManager {
        Log.trace()
        managedTableView.tableFooterView = UIView()
        let tableManager = PracticeLogTableManager(tableView, managedVC: self)
        return tableManager
    }
}
