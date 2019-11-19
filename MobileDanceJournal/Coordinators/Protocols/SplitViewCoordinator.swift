//
//  SplitViewCoordinator.swift
//  MobileDanceJournal
//
//  Created by Zach Lockett-Streiff on 7/2/19.
//  Copyright © 2019 Swingaroo2. All rights reserved.
//

import Foundation
import UIKit

/**
 Protocol for implementing the Coordinator pattern in navigation hierarchy with a UISplitViewController at its root
 */
protocol SplitViewCoordinator: Coordinator {
    var rootVC: SplitViewRootController { get }
    func start()
}
