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
    var pickerManager: PickerManager! { get set }
    
    init(_ videoToMove: PracticeVideo, from oldPracticeLog: PracticeSession, to newPracticeLogs: [PracticeSession], _ coreDataManager: CoreDataManager, managedView: UIView)
}

extension ToolbarPickerView {
    func show() {
        let newY = self.getY() - self.getHeight() + 40
        UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.01, options: .curveEaseOut, animations: { self.setY(newY)}, completion: nil)
    }
    
    func hide() {
        let newY = self.getY() + self.getHeight()
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: { self.setY(newY) }, completion: nil)
    }
}

/////////
protocol PickerManager: UIPickerViewDelegate, UIPickerViewDataSource {
    var managedPickerView: ToolbarPickerView { get }
    var coreDataManager: CoreDataManager { get }
    
    func doneButtonPressed()
    func cancelButtonPressed()
}
