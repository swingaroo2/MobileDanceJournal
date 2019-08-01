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
}

extension AppDelegate: UIApplicationDelegate {
    
    func application(_ application: UIApplication,
                       didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let rootVC = RootViewController.instantiate()
        let coreDataManager = CoreDataManager(modelName: ModelConstants.modelName)
        let _ = coreDataManager.persistentContainer
        initializeCoordinator(with: rootVC, coreDataManager)
        window = UIWindow.createNewWindow(with: rootVC)
        return true
    }
}

extension AppDelegate {
    private func initializeCoordinator(with rootVC: RootViewController,_ coreDataManager: CoreDataManager) {
        coordinator = MainCoordinator(with: rootVC, coreDataManager)
        coordinator?.start()
    }
}
