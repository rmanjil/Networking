//
//  AppDelegate.swift
//  Networking
//
//  Created by manjil on 30/03/2023.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        Networking.initialize(with: deployment.networkConfig)
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}


let deployment: Environment = {
    #if DEBUG
    return .debug
    #endif
    return .release
}()

enum Environment {
    case debug
    case release
    
    var networkConfig: NetworkingConfiguration {
        switch self {
            
        case .debug:
          return  NetworkingConfiguration(baseURL: "https://staging.foodmandu.com/webapi/api/v2",
                                          clientId: "",
                                          clientSecret: "")
        case .release:
         return  NetworkingConfiguration(baseURL: "https://foodmandu.com/webapi/api/v2",
                                         clientId: "",
                                         clientSecret: "")
        }
    }
    
}
