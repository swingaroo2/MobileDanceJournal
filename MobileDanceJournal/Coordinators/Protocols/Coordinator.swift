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

// MARK: - Default function definitions
extension Coordinator {
    func dismiss(_ viewController: UIViewController, completion: (() -> Void)?) {
        Log.trace()
        viewController.dismiss(animated: true, completion: completion)
    }
}

// MARK: - Optional functions
extension Coordinator {
    func clearDetailVC() {
        Log.trace("\(#function) Adopting class should implement")
    }
    
    func showDetails(for practiceSession: PracticeSession) {
        Log.trace("\(#function) Adopting class should implement")
    }
    
    func share(_ url: URL) {
        Log.trace("\(#function) Adopting class should implement")
    }
}
