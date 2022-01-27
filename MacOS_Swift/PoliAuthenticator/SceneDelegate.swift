//
//  SceneDelegate.swift
//  PoliAuthenticator
//
//

import UIKit
import Darwin

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        #if targetEnvironment(macCatalyst)
        windowScene.sizeRestrictions?.minimumSize = CGSize(width: 640, height: 300)
        windowScene.sizeRestrictions?.maximumSize = CGSize(width: 640, height: 300)
        guard let vc = windowScene.windows.first?.rootViewController else {return}
        checkForUpdates(viewController: vc)
        #endif
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        StatusManager.isUrl = true
        StatusManager.registerForStatus(statusManagerDelegate: self)
    }
    
    func checkForUpdates(viewController: UIViewController) {
        
        var request = URLRequest(url: URL(string: AppConst.APP_INFO)!)
        request.httpMethod = "GET"
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let _ = error {
                return
            }
            let response = response as! HTTPURLResponse
            let status = response.statusCode
            guard (200...299).contains(status) else {
                return
            }
            if let d = data {
                do {
                    let response = try JSONSerialization.jsonObject(with: d, options: []) as? [String:Any]
                        if let json = response {
                            if let platforms = json["platforms"] as? [[String:Any]] {
                                for p in platforms {
                                    guard let platform = p["os"] as? String else {return}
                                    if platform == "macOS"{
                                        guard let version = p["latest_version"] as? String else {return}
                                        guard let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String else {return}
                                        if self.isUpdateAvailable(current: currentVersion, online: version){
                                            let downloadURL = (p["download_url"] as? String) ?? ""
                                            DispatchQueue.main.async {
                                                let alert = UIAlertController(title: "Update", message: "An update is available, download it from " + downloadURL, preferredStyle: .alert)
                                                let linkAttributes = [
                                                    NSAttributedString.Key.link: NSURL(string: downloadURL)!,
                                                    NSAttributedString.Key.foregroundColor: UIColor.blue
                                                ] as [NSAttributedString.Key : Any]
                                                let attributedString = NSMutableAttributedString(string: "An update is available, download it from here")
                                                attributedString.setAttributes(linkAttributes, range: NSMakeRange(41, 4))
                                                alert.setValue(attributedString, forKey: "attributedMessage")
                                                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                                                viewController.present(alert, animated: true, completion: nil)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                } catch {
                    return
                }
            }
        }
        task.resume()
    }
    
    func isUpdateAvailable(current: String, online: String) -> Bool {
        let splittedCurrent = current.split(separator: ".")
        let splittedOnline = online.split(separator: ".")
        var index = 0
        while(index <= 2){
            let int1 = Int(splittedCurrent[index]) ?? 0
            let int2 = Int(splittedOnline[index]) ?? 0
            if(int2>int1){
                return true
            }
            index = index + 1
        }
        return false
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}

extension SceneDelegate: StatusManagerDelegate {
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
