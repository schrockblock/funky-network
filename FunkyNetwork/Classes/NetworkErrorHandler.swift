//
//  NetworkErrorHandler.swift
//  Pods
//
//  Created by Elliot Schrock on 9/11/17.
//
//

import UIKit

public protocol ErrorMessage {
    var title: String { get }
    var message: String { get }
    var forCode: Int { get }
}

public protocol NetworkErrorHandler {
    static var errorMessages: [ErrorMessage]? { get }
    static func handleError(error: NSError) -> Bool
}

public struct DefaultServerUnavailableErrorMessage: ErrorMessage {
    public let title: String = "Ruh Roh"
    public let message: String = "The server is unavailable! Try again in a bit. If this keeps happening, please let us know!"
    public let forCode: Int = 503
}

public struct DefaultServerIssueErrorMessage: ErrorMessage {
    public let title: String = "Ruh Roh"
    public let message: String = "Looks like we're having a problem. Please let us know about it!"
    public let forCode: Int = 500
}

public struct DefaultOfflineErrorMessage: ErrorMessage {
    public let title: String = "Hmmm..."
    public let message: String = "Looks like you're offline. Try reconnecting to the internet!"
    public let forCode: Int = -1009
}

public class DefaultNetworkErrorHandler: NetworkErrorHandler {
    public static let errorMessages: [ErrorMessage]? = [DefaultServerUnavailableErrorMessage(), DefaultServerIssueErrorMessage(), DefaultOfflineErrorMessage()]
    
    public static func handleError(error: NSError) -> Bool {
        if let errorMessage = errorMessageForCode(code: error.code) {
            self.notify(title: errorMessage.title, message: errorMessage.message)
            return true
        }
        return false
    }
    
    static func errorMessageForCode(code: Int) -> ErrorMessage? {
        if let messages = self.errorMessages {
            for errorMessage in messages {
                if code == errorMessage.forCode {
                    return errorMessage
                }
            }
        }
        return nil
    }
    
    public static func notify(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
        }))
        alert.show()
    }
}

extension UIAlertController {
    public func show(animated flag: Bool = true, completion: (() -> Void)? = nil) {
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = UIViewController()
        window.backgroundColor = UIColor.clear
        window.windowLevel = UIWindowLevelAlert
        
        if let rootViewController = window.rootViewController {
            window.makeKeyAndVisible()
            
            rootViewController.present(self, animated: flag, completion: completion)
        }
    }
}
