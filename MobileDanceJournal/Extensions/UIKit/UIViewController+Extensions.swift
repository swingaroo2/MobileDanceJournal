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
        Log.trace()
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        Log.trace()
        view.endEditing(true)
    }
}


// MARK: - AlertHelper
extension UIViewController {
    func presentBasicAlert(title: String? = nil, message: String) {
        Log.trace("ALERT Title: \(title ?? "NIL") Message: \(message)")
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: Actions.ok, style: .cancel, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    
    func presentYesNoAlert(title: String? = nil, message: String, isDeleteAlert: Bool, yesAction: @escaping (((UIAlertAction) -> Void)), noAction: (((UIAlertAction) -> Void))? = nil) {
        Log.trace("ALERT Title: \(title ?? "NIL") Message: \(message)")
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let yesAction = UIAlertAction(title: Actions.yes, style: (isDeleteAlert ? .destructive : .default), handler: yesAction)
        let noAction = UIAlertAction(title: Actions.onSecondThought, style: .cancel, handler: noAction)
        alert.addAction(noAction)
        alert.addAction(yesAction)
        present(alert, animated: true, completion: nil)
    }
}
