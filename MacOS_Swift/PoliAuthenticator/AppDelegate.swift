//
//  AppDelegate.swift
//  PoliAuthenticator
//
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        return true
    }
    
    func application(_ application: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey : Any] = [:] ) -> Bool {
        StatusManager.isUrl = true
        StatusManager.registerForStatus(statusManagerDelegate: self)
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

extension AppDelegate: StatusManagerDelegate {
    func onStatusUpdate(appStatus: AppStatus) {
        if(StatusManager.isUrl && appStatus == .TOKEN_VALID){
            if(!SharedPreferencesManager.isUsinsPin()){
                guard let accessToken = SharedPreferencesManager.getAccessToken(withPin: false, pin: "") else {return}
                let poliUrl = AppConst.WEBEEP_URL + accessToken
                UIApplication.shared.open(URL(string: poliUrl)!) { _ in
                    exit(0)
                }
            } else {
                
                guard let accessToken = SharedPreferencesManager.getAccessToken(withPin: true, pin: StatusManager.pin) else {return}
                let poliUrl = AppConst.WEBEEP_URL + accessToken
                UIApplication.shared.open(URL(string: poliUrl)!) { _ in
                    exit(0)
                }
                    
            }
        }
    
    }
}
