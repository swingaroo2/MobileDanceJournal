//
//  NewGroupVC.swift
//  MobileDanceJournal
//
//  Created by Zach Lockett-Streiff on 8/20/19.
//  Copyright © 2019 Swingaroo2. All rights reserved.
//

import UIKit


// TODO: Add search to table view
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
        setUpView()
        tableManager = configureTableManager(tableView, coreDataManager)
    }
    
    private func setUpView() {
        groupNameTextField.delegate = self
        guard let text = groupNameTextField.text else { return }
        saveButton.isEnabled = !text.isEmpty
        groupNameTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        guard let text = textField.text else { return }
        saveButton.isEnabled = !text.isEmpty
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
                let selectedPracticeSessions = tableManager.getSelectedPracticeSessions()
                coreDataManager.createAndSaveNewGroup(name: groupNameTextField.text!, practiceSessions: selectedPracticeSessions)
                break
            case cancelButton:
                break
            default:
                break
        }
        
        coordinator.dismiss(self, completion: nil)
    }
    
}

extension NewGroupVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
