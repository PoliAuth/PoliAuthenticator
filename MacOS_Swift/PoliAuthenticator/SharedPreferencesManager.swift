//
//  SharedPreferencesManager.swift
//  PoliBrowser
//
//

import Foundation
import UIKit

class SharedPreferencesManager {
    
    public static func setAccessToken(accessToken: String) {
        UserDefaults.standard.set(accessToken, forKey: "access_token")
    }
    
    public static func setRefreshToken(refreshToken: String) {
        UserDefaults.standard.set(refreshToken, forKey: "refresh_token")
    }
    
    public static func setTokenExpire(expireAt: String) {
        UserDefaults.standard.set(expireAt, forKey: "token_expire")
    }
    
    public static func setUserPin(usePin: Bool, pin: String) {
        if usePin {
            if !SharedPreferencesManager.isPinConfigured(){
                SharedPreferencesManager.setRefreshToken(refreshToken: try! Utils.encryptMessage(message: UserDefaults.standard.string(forKey: "refresh_token")!, encryptionKey: pin))
            }
            SharedPreferencesManager.setAccessToken(accessToken: try! Utils.encryptMessage(message: UserDefaults.standard.string(forKey: "access_token")!, encryptionKey: pin))
            UserDefaults.standard.set(true, forKey: "use_pin")
            UserDefaults.standard.set(pin.sha256(), forKey: "pin")
        } else {
            UserDefaults.standard.set(false, forKey: "use_pin")
            UserDefaults.standard.set("none", forKey: "pin")
        }
    }
    
    public static func isUserLogged() -> Bool {
        return !(UserDefaults.standard.string(forKey: "access_token") == nil ? true : false)
    }
    
    public static func isUsinsPin() -> Bool {
        return UserDefaults.standard.bool(forKey: "use_pin")
    }
    
    public static func isPinConfigured() -> Bool {
        return !(UserDefaults.standard.string(forKey: "pin") == nil ? true : false)
    }
    
    public static func getAccessToken(withPin: Bool, pin: String) -> String? {
        if withPin {
            return try! Utils.decryptMessage(encryptedMessage: UserDefaults.standard.string(forKey: "access_token")!, encryptionKey: pin)
        }
        return UserDefaults.standard.string(forKey: "access_token")
    }
    
    public static func getRefreshToken(withPin: Bool, pin: String) -> String? {
        if withPin {
            return try! Utils.decryptMessage(encryptedMessage: UserDefaults.standard.string(forKey: "refresh_token")!, encryptionKey: pin)
        }
        return UserDefaults.standard.string(forKey: "refresh_token")
    }
    
    public static func getExpiration() -> String? {
        return UserDefaults.standard.string(forKey: "token_expire")
    }
    
    public static func getAuthPin() -> String? {
        return UserDefaults.standard.string(forKey: "pin")
    }
    
    public static func deletePreferences() {
        UserDefaults.standard.removeObject(forKey: "token_expire")
        UserDefaults.standard.removeObject(forKey: "refresh_token")
        UserDefaults.standard.removeObject(forKey: "access_token")
        UserDefaults.standard.removeObject(forKey: "use_pin")
        UserDefaults.standard.removeObject(forKey: "pin")
    }
}
