//
//  Utils.swift
//  PoliBrowser
//
//

import Foundation
import UIKit
import CommonCrypto

class Utils {
    public static func getNow23h() -> String {
        var date = ""
        let now23 = Date().addingTimeInterval(23*60*60)
        let formatter = DateFormatter()
        formatter.timeZone = Calendar.current.timeZone
        formatter.locale = Calendar.current.locale
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        date = formatter.string(from: now23)
        return date
    }
    
    public static func isTokenValid() -> Bool{
        let formatter = DateFormatter()
        formatter.timeZone = Calendar.current.timeZone
        formatter.locale = Calendar.current.locale
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        if let savedDate = formatter.date(from: SharedPreferencesManager.getExpiration()!){
            if(savedDate > Date()){
                return true
            }
        }
        return false
    }
    
    public static func encryptMessage(message: String, encryptionKey: String) throws -> String {
           let messageData = message.data(using: .utf8)!
           let cipherData = RNCryptor.encrypt(data: messageData, withPassword: encryptionKey)
           return cipherData.base64EncodedString()
       }

    public static func decryptMessage(encryptedMessage: String, encryptionKey: String) throws -> String {

           let encryptedData = Data.init(base64Encoded: encryptedMessage)!
           let decryptedData = try RNCryptor.decrypt(data: encryptedData, withPassword: encryptionKey)
           let decryptedString = String(data: decryptedData, encoding: .utf8)!

           return decryptedString
       }
    
}

extension Data{
    public func sha256() -> String{
        return hexStringFromData(input: digest(input: self as NSData))
    }
    
    private func digest(input : NSData) -> NSData {
        let digestLength = Int(CC_SHA256_DIGEST_LENGTH)
        var hash = [UInt8](repeating: 0, count: digestLength)
        CC_SHA256(input.bytes, UInt32(input.length), &hash)
        return NSData(bytes: hash, length: digestLength)
    }
    
    private  func hexStringFromData(input: NSData) -> String {
        var bytes = [UInt8](repeating: 0, count: input.length)
        input.getBytes(&bytes, length: input.length)
        
        var hexString = ""
        for byte in bytes {
            hexString += String(format:"%02x", UInt8(byte))
        }
        
        return hexString
    }
}

public extension String {
    func sha256() -> String{
        if let stringData = self.data(using: String.Encoding.utf8) {
            return stringData.sha256()
        }
        return ""
    }
}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
