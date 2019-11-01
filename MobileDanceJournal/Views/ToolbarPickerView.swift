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
}

extension ToolbarPickerView {
    var toolbarHeight: CGFloat { return 44.0 }
    
    func show() {
        Log.trace()
        let newY = self.getY() - self.getHeight() + 40
        UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.01, options: .curveEaseOut, animations: { self.setY(newY)}, completion: nil)
    }
    
    func hide() {
        Log.trace()
        let newY = self.getY() + self.getHeight()
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: { self.setY(newY) }, completion: nil)
    }
    
    func configureView(in parentView: UIView,_ barButtonItems: [UIBarButtonItem]) {
        Log.trace()
        configureContainerView(parentView)
        addPickerView()
        addToolbar(barButtonItems)
    }
    
    func configureContainerView(_ parentView: UIView) {
        Log.trace()
        let height = picker.getHeight() + toolbarHeight
        frame = CGRect(x: 0, y: parentView.getHeight(), width: parentView.getWidth(), height: height)
        backgroundColor = .black
        parentView.addSubview(self)
        widthAnchor.constraint(equalTo: parentView.widthAnchor).isActive = true
    }
    
    func addPickerView() {
        Log.trace()
        addSubview(picker)
        picker.setWidth(getWidth())
        picker.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
    }
    
    func addToolbar(_ barButtonItems: [UIBarButtonItem]) {
        Log.trace()
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
