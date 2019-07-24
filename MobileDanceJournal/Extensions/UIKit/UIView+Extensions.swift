//
//  UIView+Extensions.swift
//  MobileDanceJournal
//
//  Created by Zach Lockett-Streiff on 5/6/19.
//  Copyright © 2019 Swingaroo2. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    func loadViewFromNib() -> UIView! {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "\(type(of: self))", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        return view
    }
    
    func xibSetup(with contentView: UIView?) {
        let contentView = loadViewFromNib()
        contentView!.frame = bounds
        contentView!.autoresizingMask = [UIView.AutoresizingMask.flexibleWidth, UIView.AutoresizingMask.flexibleHeight]
        addSubview(contentView!)
    }
    
    // MARK: - Frame convenience methods
    func getWidth(multiplier: CGFloat = 1.0) -> CGFloat {
        return frame.size.width * multiplier
    }
    
    func setWidth(_ width: CGFloat) {
        frame.size = CGSize(width: width, height: frame.size.height)
    }
    
    func getHeight(multiplier: CGFloat = 1.0) -> CGFloat {
        return frame.size.height * multiplier
    }
    
    func setHeight(_ height: CGFloat) {
        frame.size = CGSize(width: frame.size.width, height: height)
    }
    
    func getY(multiplier: CGFloat = 1.0) -> CGFloat {
        return frame.origin.y
    }
    
    func setY(_ newY: CGFloat) {
        frame.origin = CGPoint(x: frame.origin.x, y: newY)
    }
    
    func getX(multiplier: CGFloat = 1.0) -> CGFloat {
        return frame.origin.x
    }
    
    func setX(_ newX: CGFloat) {
        frame.origin = CGPoint(x: newX, y: frame.origin.x)
    }
}
