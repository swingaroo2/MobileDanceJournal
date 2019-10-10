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
    var editingGroup: Group?
    
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var groupNameTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var ungroupedPracticeLogsLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableManager = configureTableManager(tableView, coreDataManager)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUpView(with: editingGroup)
    }
    
    func setUpView(with group: Group?) {
        groupNameTextField.delegate = self
        groupNameTextField.text = editingGroup?.name
        guard let text = groupNameTextField.text else { return }
        saveButton.isEnabled = !text.isEmpty
        groupNameTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        guard let ungroupedPracticeSessions = coreDataManager.fetchPracticeSessions(in: nil) else { return }
        ungroupedPracticeLogsLabel.isHidden = (ungroupedPracticeSessions.count == 0)
    }
    
    private func configureTableManager(_ managedTableView: UITableView,_ coreDataManager: CoreDataManager) -> PracticeLogTableManager {
        managedTableView.tableFooterView = UIView()
        let tableManager = PracticeLogTableManager(tableView, coreDataManager, managedVC: self)
        return tableManager
    }
    
    @IBAction func buttonPressed(_ sender: UIButton) {
        switch sender {
            case saveButton:
                let selectedPracticeSessions = tableManager.getSelectedPracticeSessions()
                
                if let group = editingGroup {
                    coreDataManager.update(group: group, name: groupNameTextField.text!, practiceSessions: selectedPracticeSessions)
                } else {
                    coreDataManager.createAndSaveNewGroup(name: groupNameTextField.text!, practiceSessions: selectedPracticeSessions)
                }
                break
            case cancelButton:
                break
            default:
                break
        }
        
        coordinator.dismiss(self, completion: nil)
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        guard let text = textField.text else { return }
        saveButton.isEnabled = !text.isEmpty
    }
}

extension NewGroupVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
