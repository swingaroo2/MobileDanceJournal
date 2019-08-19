//
//  SplitViewCoordinator.swift
//  MobileDanceJournal
//
//  Created by Zach Lockett-Streiff on 7/2/19.
//  Copyright © 2019 Swingaroo2. All rights reserved.
//

import Foundation
import UIKit

protocol SplitViewCoordinator: Coordinator {
    var rootVC: SplitViewRootController { get }
}

extension SplitViewCoordinator where Self: Coordinator {}
