//
//  AppDelegate.swift
//  MobileDanceJournal
//
//  Created by Zach Lockett-Streiff on 4/21/19.
//  Copyright © 2019 Swingaroo2. All rights reserved.
//

import UIKit
import CoreData
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder {
    var window: UIWindow?
    var coordinator: MainCoordinator?
    var coreDataManager: CoreDataManager?
}

extension AppDelegate: UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        Log.trace()
        initializeLogger()
        initializeFirebase()
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
        Log.trace()
        self.coreDataManager?.save()
    }
}

// MARK: - Private Methods
private extension AppDelegate {
    func startCoordinator(with rootVC: SplitViewRootController,_ coreDataManager: CoreDataManager) {
        Log.trace()
        coordinator = MainCoordinator(rootVC, coreDataManager)
        coordinator?.start()
    }
    
    func initializeLogger() {
        Log.logLevel = .trace
        Log.trace()
    }
    
    func initializeFirebase() {
        FirebaseConfiguration.shared.setLoggerLevel(.min)
        FirebaseApp.configure()
    }
}
