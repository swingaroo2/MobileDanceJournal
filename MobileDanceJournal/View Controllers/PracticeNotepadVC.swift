//
//  PracticeNotepadVC.swift
//  MobileDanceJournal
//
//  Created by Zach Lockett-Streiff on 4/21/19.
//  Copyright © 2019 Swingaroo2. All rights reserved.
//

import UIKit

class PracticeNotepadVC: UIViewController, Storyboarded {

    // MARK: - IBOutlets
    @IBOutlet weak var noContentLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var practiceSessionTitleTextView: UITextView!
    @IBOutlet weak var practiceSessionDateLabel: UILabel!
    @IBOutlet weak var practiceSessionContent: UITextView!
    @IBOutlet var cameraButton: UIBarButtonItem!
    @IBOutlet var saveButton: UIBarButtonItem!
    
    var practiceSession: PracticeSession?
    var coreDataManager: CoreDataManager!
    var textViewManager: NotepadTextViewManager!
    weak var coordinator: MainCoordinator?
    
    // MARK: Lifecycle functions
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpKeyboardListeners()
        practiceSessionTitleTextView.delegate = textViewManager
        practiceSessionContent.delegate = textViewManager
    }
    
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
    }
    
    private func ensureNotesTextViewIsScrolledToTop() {
        // Yes, this is a total hack. It has, however, lead to a rather cool animation when opening a practice session. So I'm keeping it.
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
            let keyboardBuffer = CGFloat(integerLiteral: 20)
            practiceSessionContent.contentInset.bottom = bottomValue + keyboardBuffer
        }
        
        practiceSessionContent.scrollIndicatorInsets = practiceSessionContent.contentInset
        
        let selectedRange = practiceSessionContent.selectedRange
        practiceSessionContent.scrollRangeToVisible(selectedRange)
    }
}
