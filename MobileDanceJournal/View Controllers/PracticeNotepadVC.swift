//
//  PracticeNotepadVC.swift
//  MobileDanceJournal
//
//  Created by Zach Lockett-Streiff on 4/21/19.
//  Copyright © 2019 Swingaroo2. All rights reserved.
//

import UIKit

class PracticeNotepadVC: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var noContentLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var practiceSessionTitleTextView: UITextView!
    @IBOutlet weak var practiceSessionDateLabel: UILabel!
    @IBOutlet weak var practiceSessionContent: UITextView!
    @IBOutlet var cameraButton: UIBarButtonItem!
    @IBOutlet var saveButton: UIBarButtonItem!
    
    var practiceSession: PracticeSession?
    weak var coordinator: MainCoordinator?
    
    var coreDataManager: CoreDataManager!
    private var keyboardShown = false
    
    // MARK: Lifecycle functions
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUpView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    
    // MARK: View Setup
    private func setUpView() {
        configureKeyboardToDismissOnOutsideTap()
        ensureNotesTextViewIsScrolledToTop()
        practiceSessionContent.flashScrollIndicators()
        saveButton.isEnabled = false
        cameraButton.isEnabled = practiceSession != nil
        
        // TODO: Keyboard handling. Scroll when typing reaches a new line.
    }
    
    private func ensureNotesTextViewIsScrolledToTop() {
        // Yes, this is a total hack. This is a placeholder while I establish MVP
        DispatchQueue.main.async {
            self.practiceSessionContent.setContentOffset(CGPoint(x: 0.0, y: -self.practiceSessionContent.contentInset.top), animated: true)
        }
    }
    
    private func setUpKeyboardListeners() {
        NotificationCenter.default.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func adjustForKeyboard(notification: Notification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        
        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
        
        if notification.name == UIResponder.keyboardWillHideNotification {
            practiceSessionContent.contentInset = .zero
        }
        else {
            let bottomValue = keyboardViewEndFrame.height - view.safeAreaInsets.bottom
            practiceSessionContent.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: bottomValue, right: 0)
        }
        
        practiceSessionContent.scrollIndicatorInsets = practiceSessionContent.contentInset
        
        let selectedRange = practiceSessionContent.selectedRange
        practiceSessionContent.scrollRangeToVisible(selectedRange)
    }
}
