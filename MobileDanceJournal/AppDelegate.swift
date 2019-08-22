//
//  AppDelegate.swift
//  MobileDanceJournal
//
//  Created by Zach Lockett-Streiff on 4/21/19.
//  Copyright © 2019 Swingaroo2. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder {
    var window: UIWindow?
    var coordinator: MainCoordinator?
    var coreDataManager: CoreDataManager?
}

extension AppDelegate: UIApplicationDelegate {
    
    func application(_ application: UIApplication,
                       didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let rootNC = UINavigationController()
        let coreDataManager = CoreDataManager(modelName: ModelConstants.modelName)
        let _ = coreDataManager.persistentContainer
        startCoordinator(with: rootNC, coreDataManager)
        self.coreDataManager = coreDataManager
        window = UIWindow.createNewWindow(with: rootNC)
        return true
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        self.coreDataManager?.save()
    }
}

extension AppDelegate {
    private func startCoordinator(with rootNC: UINavigationController,_ coreDataManager: CoreDataManager) {
        coordinator = MainCoordinator(rootNC, coreDataManager)
        coordinator?.start()
    }
}
