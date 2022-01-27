//
//  TaskManager.swift
//  PoliBrowser
//
//

import Foundation
import UIKit

protocol TaskManagerDelegate {
    func taskManager(taskManager: TaskManager, didFinishWith result: Bool, stringContent: String) -> Void
}

class TaskManager: NSObject {
    open var delegate: TaskManagerDelegate? = nil
    private var url: URL!
    private var parameters: [String: Any]!
    
    required init(url: URL, parameters: [String: Any]) {
        self.url = url
        self.parameters = parameters
    }
    
    public func execute() {
        var request = URLRequest(url: self.url)
        request.httpMethod = "POST"
        request.httpBody = self.parameters.percentEncoded()
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                self.delegate?.taskManager(taskManager: self, didFinishWith: false, stringContent: error.localizedDescription)
                return
            }
            let response = response as! HTTPURLResponse
            let status = response.statusCode
            guard (200...299).contains(status) else {
                self.delegate?.taskManager(taskManager: self, didFinishWith: false, stringContent: "Error: \(status)")
                return
            }
            if let d = data {
                if let s = String(data: d, encoding: .utf8) {
                    self.delegate?.taskManager(taskManager: self, didFinishWith: true, stringContent: s)
                } else {
                    self.delegate?.taskManager(taskManager: self, didFinishWith: false, stringContent: "Data conversion error")
                }
            } else {
                self.delegate?.taskManager(taskManager: self, didFinishWith: false, stringContent: "Data reading error")
            }
        }
        task.resume()
    }
    
}

extension TaskManagerDelegate {
    func taskManager(taskManager: TaskManager, didFinishWith result: Bool, stringContent: String) -> Void {}
}

extension Dictionary {
    func percentEncoded() -> Data? {
        return map { key, value in
            let escapedKey = "\(key)".addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? ""
            let escapedValue = "\(value)".addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? ""
            return escapedKey + "=" + escapedValue
        }
        .joined(separator: "&")
        .data(using: .utf8)
    }
}

extension CharacterSet {
    static let urlQueryValueAllowed: CharacterSet = {
        let generalDelimitersToEncode = ":#[]@" // does not include "?" or "/" due to RFC 3986 - Section 3.4
        let subDelimitersToEncode = "!$&'()*+,;="

        var allowed = CharacterSet.urlQueryAllowed
        allowed.remove(charactersIn: "\(generalDelimitersToEncode)\(subDelimitersToEncode)")
        return allowed
    }()
}
