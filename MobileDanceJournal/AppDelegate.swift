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
}

extension AppDelegate: UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        initializeLogger()
        Log.trace()
        initializeFirebase()
        Services.start()
        Model.start()
        let rootVC = SplitViewRootController.instantiate()
        startCoordinator(with: rootVC)
        window = UIWindow.createNewWindow(with: rootVC)
        return true
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        Log.trace()
        Model.coreData.save()
    }
}

// MARK: - Private Methods
private extension AppDelegate {
    func startCoordinator(with rootVC: SplitViewRootController) {
        Log.trace()
        coordinator = MainCoordinator(rootVC)
        coordinator?.start()
    }
    
    func initializeLogger() {
        Log.logLevel = .trace
        Log.trace()
    }
    
    func initializeFirebase() {
        Log.logLevel = .trace
        FirebaseConfiguration.shared.setLoggerLevel(.min)
        FirebaseApp.configure()
    }
}
