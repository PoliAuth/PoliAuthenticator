//
//  StatusManager.swift
//  PoliBrowser
//
//

import Foundation
import UIKit

protocol StatusManagerDelegate {
    func onStatusUpdate(appStatus: AppStatus)
}


class StatusManager {
    public static var isUrl: Bool = false
    public static var pin: String = ""
    private static var observers: [StatusManagerDelegate] = []
    private static var currentStatus: AppStatus = .UNLOGGED
    
    public static func registerForStatus(statusManagerDelegate: StatusManagerDelegate){
        self.observers.append(statusManagerDelegate)
        statusManagerDelegate.onStatusUpdate(appStatus: self.currentStatus)
    }
    
    public static func notifyStatusUpdate(status: AppStatus){
        self.currentStatus = status
        for o in self.observers {
            o.onStatusUpdate(appStatus: self.currentStatus)
        }
    }
    
    
    public func updateAppToken() {
        if (!SharedPreferencesManager.isUserLogged()) {return}
        if (SharedPreferencesManager.isUsinsPin() && StatusManager.pin == "") {return}
        
            if(!Utils.isTokenValid()){
                StatusManager.notifyStatusUpdate(status: .TOKEN_NOT_VALID)
                if let refreshToken = SharedPreferencesManager.getRefreshToken(withPin: SharedPreferencesManager.isUsinsPin(), pin: StatusManager.pin){
                    let parameters: [String:Any] = [
                        "grant_type" : "refresh_token",
                        "refresh_token" : refreshToken,
                        "client_id" : AppConst.CLIENT_ID,
                        "client_secret" : AppConst.CLIENT_SECRET,
                        "redirect_uri" : AppConst.REDIRECT_URI
                    ]
                    let task = TaskManager(url: URL(string: AppConst.TOKEN_SERVER)!, parameters: parameters)
                    task.delegate = self
                    task.execute()
                }
            } else {
                StatusManager.notifyStatusUpdate(status: .TOKEN_VALID)
            }
    }
    
    public func getAccessToken(usingAuthToken authToken: String){
        let parameters: [String: Any] = [
            "grant_type" : "authorization_code",
            "code" : authToken,
            "client_id" : AppConst.CLIENT_ID,
            "client_secret" : AppConst.CLIENT_SECRET,
            "redirect_uri" : AppConst.REDIRECT_URI
        ]
        let task = TaskManager(url: URL(string: AppConst.TOKEN_SERVER)!, parameters: parameters)
        task.delegate = self
        task.execute()
    }
    
}

extension StatusManager: TaskManagerDelegate {
    func taskManager(taskManager: TaskManager, didFinishWith result: Bool, stringContent: String) {
        if result{
            if let data = stringContent.data(using: .utf8) {
                do {
                    let response = try JSONSerialization.jsonObject(with: data, options: []) as? [String:Any]
                    if let json = response {
                        if let aToken = json["access_token"] as? String {
                            if(SharedPreferencesManager.isUsinsPin()){
                                SharedPreferencesManager.setAccessToken(accessToken: aToken)
                                SharedPreferencesManager.setTokenExpire(expireAt: Utils.getNow23h())
                                SharedPreferencesManager.setUserPin(usePin: true, pin: StatusManager.pin)
                            } else {
                                SharedPreferencesManager.setAccessToken(accessToken: aToken)
                                SharedPreferencesManager.setTokenExpire(expireAt: Utils.getNow23h())
                            }
                        } else {
                            SharedPreferencesManager.deletePreferences()
                            StatusManager.notifyStatusUpdate(status: .UNLOGGED)
                            return
                        }
                        if let rToken = json["refresh_token"] as? String {
                            SharedPreferencesManager.setRefreshToken(refreshToken: rToken)
                        }
                        DispatchQueue.main.async {
                            StatusManager.notifyStatusUpdate(status: .TOKEN_VALID)
                        }
                    }
                } catch {
                    SharedPreferencesManager.deletePreferences()
                    StatusManager.notifyStatusUpdate(status: .UNLOGGED)
                }
            }
        } else {
            DispatchQueue.main.async {
                
            
            let keyWindow = UIApplication.shared.windows.filter {$0.isKeyWindow}.first

            if var topController = keyWindow?.rootViewController {
                while let presentedViewController = topController.presentedViewController {
                    topController = presentedViewController
                }
                let alert = UIAlertController(title: "Error", message: stringContent, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Close", style: .default, handler: nil))
            
                    topController.present(alert, animated: true, completion: {
                        StatusManager.notifyStatusUpdate(status: .UNLOGGED)
                    })
                }
            }
        }
    }
}
