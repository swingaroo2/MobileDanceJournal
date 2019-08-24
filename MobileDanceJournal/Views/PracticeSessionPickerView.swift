//
//  PracticeSessionPickerView.swift
//  MobileDanceJournal
//
//  Created by Zach Lockett-Streiff on 7/23/19.
//  Copyright © 2019 Swingaroo2. All rights reserved.
//

import Foundation
import UIKit

class PracticeSessionPickerView: UIView, ToolbarPickerView {
    
    var picker: UIPickerView
    var pickerManager: PickerManager!
    let toolbarHeight: CGFloat = 44.0
    
    required init(_ videoToMove: PracticeVideo, from oldPracticeLog: PracticeSession, to newPracticeLogs: [PracticeSession],_ coreDataManager: CoreDataManager, managedView: UIView) {
        self.picker = UIPickerView()
        super.init(frame: .zero)
        self.pickerManager = self.configureManager(videoToMove, oldPracticeLog, newPracticeLogs, coreDataManager)
        self.picker.dataSource = self.pickerManager
        self.picker.delegate = self.pickerManager
        configureView(in: managedView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.picker = UIPickerView()
        super.init(coder: aDecoder)
    }
    
    func show() {
        let newY = self.getY() - self.getHeight() + 40
        UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.01, options: .curveEaseOut, animations: { self.setY(newY)}, completion: nil)
    }
    
    func hide() {
        let newY = self.getY() + self.getHeight()
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: { self.setY(newY) }, completion: nil)
    }
    
    private func configureManager(_ videoToMove: PracticeVideo,_ oldPracticeLog: PracticeSession,_ newPracticeLogs: [PracticeSession],_ coreDataManager: CoreDataManager) -> PracticeSessionPickerManager {
        let manager = PracticeSessionPickerManager(self, coreDataManager)
        manager.oldPracticeSession = oldPracticeLog
        manager.practiceSessions = newPracticeLogs
        manager.videoToMove = videoToMove
        return manager
    }
    
    private func configureView(in parentView: UIView) {
        configureContainerView(parentView)
        addPickerView()
        addToolbar()
    }
    
    private func configureContainerView(_ parentView: UIView) {
        let height = picker.getHeight() + toolbarHeight
        frame = CGRect(x: 0, y: parentView.getHeight(), width: parentView.getWidth(), height: height)
        backgroundColor = .black
        parentView.addSubview(self)
        widthAnchor.constraint(equalTo: parentView.widthAnchor).isActive = true
    }
    
    private func addPickerView() {
        addSubview(picker)
        picker.setWidth(getWidth())
        picker.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
    }
    
    private func addToolbar() {
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: getWidth(), height: toolbarHeight))
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: pickerManager, action: #selector(PracticeSessionPickerManager.doneButtonPressed))
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: pickerManager, action: #selector(PracticeSessionPickerManager.cancelButtonPressed))
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbar.setItems([doneButton, spacer, cancelButton], animated: false)
        toolbar.barStyle = .default
        toolbar.barTintColor = .black
        toolbar.tintColor = .white
        toolbar.isTranslucent = true
        
        addSubview(toolbar)
        toolbar.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
    }
}
