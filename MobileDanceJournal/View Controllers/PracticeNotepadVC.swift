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
    
    var practiceSession: PracticeSession!
    var textViewManager: NotepadTextViewManager!
    weak var coordinator: PracticeLogCoordinator!
    
    // MARK: - Lifecycle Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        Log.trace()
        setUpKeyboardListeners()
        practiceSessionTitleTextView.delegate = textViewManager
        practiceSessionContent.delegate = textViewManager
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Log.trace()
        setUpView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        Log.trace()
        NotificationCenter.default.removeObserver(self)
    }
    
}

// MARK: - View State Handlers
extension PracticeNotepadVC {
    func updateView(with practiceSession: PracticeSession) {
        Log.trace()
        practiceSessionTitleTextView.configure(with: practiceSession, for: PracticeSessionConstants.title)
        practiceSessionDateLabel.configure(with: practiceSession, for: PracticeSessionConstants.date)
        practiceSessionContent.configure(with: practiceSession, for: PracticeSessionConstants.notes)
    }

    func hideContent() {
        Log.trace()
        scrollView.isHidden = true
        noContentLabel.isHidden = false
        saveButton.isEnabled = false
        cameraButton.isEnabled = false
    }

    func showContent() {
        Log.trace()
        scrollView.isHidden = false
        noContentLabel.isHidden = true
    }
}

// MARK: - IBActions
extension PracticeNotepadVC {
    @IBAction func saveButtonPressed(_ sender: UIBarButtonItem) {
        Log.trace()
        practiceSessionTitleTextView.resignFirstResponder()
        practiceSessionContent.resignFirstResponder()
        saveButton.isEnabled = false
    }
    
    @IBAction func cameraButtonPressed(_ sender: UIBarButtonItem) {
        Log.trace()
        coordinator?.viewVideos(for: practiceSession)
    }
}

// MARK: - Private Methods
private extension PracticeNotepadVC {
    @objc func adjustForKeyboard(notification: Notification) {
        Log.trace()
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {
            Log.error("Failed to get keyboard frame-end value")
            return
        }
        
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
    
    func setUpView() {
        Log.trace()
        configureKeyboardToDismissOnOutsideTap()
        ensureNotesTextViewIsScrolledToTop()
        practiceSessionContent.flashScrollIndicators()
        saveButton.isEnabled = false
        cameraButton.isEnabled = practiceSession != nil
    }
    
    func ensureNotesTextViewIsScrolledToTop() {
        Log.trace()
        // Yes, this is a total hack. It has, however, lead to a dope animation when opening a practice session. So I'm keeping it.
        DispatchQueue.main.async {
            self.practiceSessionContent.setContentOffset(CGPoint(x: 0.0, y: -self.practiceSessionContent.contentInset.top), animated: true)
        }
    }
    
    func setUpKeyboardListeners() {
        Log.trace()
        NotificationCenter.default.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
}
