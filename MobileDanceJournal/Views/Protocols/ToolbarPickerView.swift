//
//  ToolbarPickerView.swift
//  MobileDanceJournal
//
//  Created by Zach Lockett-Streiff on 8/24/19.
//  Copyright © 2019 Swingaroo2. All rights reserved.
//

import Foundation
import UIKit

protocol ToolbarPickerView: UIView {
    var picker: UIPickerView { get set }
    var manager: PickerManager! { get set }
    
    init(_ videoToMove: PracticeVideo, from oldPracticeLog: PracticeSession, to newPracticeLogs: [PracticeSession], _ coreDataManager: CoreDataManager, managedView: UIView)
}

extension ToolbarPickerView {
    var toolbarHeight: CGFloat { return 44.0 }
    
    func show() {
        let newY = self.getY() - self.getHeight() + 40
        UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.01, options: .curveEaseOut, animations: { self.setY(newY)}, completion: nil)
    }
    
    func hide() {
        let newY = self.getY() + self.getHeight()
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: { self.setY(newY) }, completion: nil)
    }
    
    func configureView(in parentView: UIView,_ barButtonItems: [UIBarButtonItem]) {
        configureContainerView(parentView)
        addPickerView()
        addToolbar(barButtonItems)
    }
    
    // TODO: Appearance protocol use case?
    func configureContainerView(_ parentView: UIView) {
        let height = picker.getHeight() + toolbarHeight
        frame = CGRect(x: 0, y: parentView.getHeight(), width: parentView.getWidth(), height: height)
        backgroundColor = .black
        parentView.addSubview(self)
        widthAnchor.constraint(equalTo: parentView.widthAnchor).isActive = true
    }
    
    func addPickerView() {
        addSubview(picker)
        picker.setWidth(getWidth())
        picker.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
    }
    
    func addToolbar(_ barButtonItems: [UIBarButtonItem]) {
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: getWidth(), height: toolbarHeight))
        toolbar.setItems(barButtonItems, animated: false)
        toolbar.barStyle = .default
        toolbar.barTintColor = .black
        toolbar.tintColor = .white
        toolbar.isTranslucent = true
        
        addSubview(toolbar)
        toolbar.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
    }
}