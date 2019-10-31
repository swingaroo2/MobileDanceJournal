//
//  AppDelegate.swift
//  MobileDanceJournal
//
//  Created by Zach Lockett-Streiff on 4/21/19.
//  Copyright © 2019 Swingaroo2. All rights reserved.
//

import UIKit
import CoreData
import Logging

var logger = Logger(label: Bundle.main.bundleIdentifier!)

@UIApplicationMain
class AppDelegate: UIResponder {
    var window: UIWindow?
    var coordinator: MainCoordinator?
    var coreDataManager: CoreDataManager?
}

extension AppDelegate: UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        logger.logLevel = .trace
        let rootVC = SplitViewRootController.instantiate()
        let coreDataManager = CoreDataManager(modelName: ModelConstants.modelName)
        rootVC.coreDataManager = coreDataManager
        let _ = coreDataManager.persistentContainer
        startCoordinator(with: rootVC, coreDataManager)
        self.coreDataManager = coreDataManager
        window = UIWindow.createNewWindow(with: rootVC)
        return true
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        self.coreDataManager?.save()
    }
}

private extension AppDelegate {
    func startCoordinator(with rootVC: SplitViewRootController,_ coreDataManager: CoreDataManager) {
        coordinator = MainCoordinator(rootVC, coreDataManager)
        coordinator?.start()
    }
}
