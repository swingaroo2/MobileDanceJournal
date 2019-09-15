//
//  Coordinator.swift
//  MobileDanceJournal
//
//  Created by Zach Lockett-Streiff on 6/29/19.
//  Copyright © 2019 Swingaroo2. All rights reserved.
//

import Foundation
import UIKit

protocol Coordinator: AnyObject {
    var childCoordinators: [Coordinator] { get set }
    var navigationController: UINavigationController { get set }
    func start()
}

// Default function definitions
extension Coordinator {
    func dismiss(_ viewController: UIViewController, completion: (() -> Void)?) {
        viewController.dismiss(animated: true, completion: completion)
    }
}

// Empty default function definitions for classes that use multiple coordinators
extension Coordinator {
    func isDisplayingBothVCs() -> Bool {
        print("\(#function) Adopting class should implement")
        return false
    }
    
    func clearDetailVC() {
        print("\(#function) Adopting class should implement")
    }
    
    func showDetails(for practiceSession: PracticeSession) {
        print("\(#function) Adopting class should implement")
    }
}
