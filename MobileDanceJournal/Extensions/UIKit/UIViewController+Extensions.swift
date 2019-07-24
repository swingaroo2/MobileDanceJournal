//
//  UIViewController+Extension.swift
//  MobileDanceJournal
//
//  Created by Zach Lockett-Streiff on 5/4/19.
//  Copyright © 2019 Swingaroo2. All rights reserved.
//

import UIKit

// MARK: - Keyboard Handling
extension UIViewController {
    func configureKeyboardToDismissOnOutsideTap() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}


// MARK: - AlertHelper
extension UIViewController {
    func presentBasicAlert(message: String) {
        presentBasicAlert(title: nil, message: message)
    }
    
    func presentBasicAlert(title: String?, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: Actions.ok, style: .cancel, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
}
