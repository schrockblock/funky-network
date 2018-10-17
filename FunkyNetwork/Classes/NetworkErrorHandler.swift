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
    var errorMessages: [ErrorMessage]? { get }
    func handleError(_ error: NSError) -> Bool
    func handleErrorCode(_ code: Int) -> Bool
    func errorMessageForCode(_ code: Int) -> ErrorMessage?
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

public struct DefaultUsernamePasswordLoginErrorMessage: ErrorMessage {
    public let title: String = "Oops!"
    public let message: String = "Looks like your username or password is incorrect. Try again!"
    public let forCode: Int = 401
}

public struct DefaultEmailPasswordLoginErrorMessage: ErrorMessage {
    public let title: String = "Oops!"
    public let message: String = "Looks like your email or password is incorrect. Try again!"
    public let forCode: Int = 401
}

public class DefaultNetworkErrorHandler: NetworkErrorHandler {
    public var errorMessages: [ErrorMessage]? = [DefaultServerUnavailableErrorMessage(), DefaultServerIssueErrorMessage(), DefaultOfflineErrorMessage()]
    
    open func handleError(_ error: NSError) -> Bool {
        if let errorMessage = errorMessageForCode(error.code) {
            self.notify(title: errorMessage.title, message: errorMessage.message)
            return true
        }
        return false
    }
    
    open func handleErrorCode(_ code: Int) -> Bool {
        if let errorMessage = errorMessageForCode(code) {
            self.notify(title: errorMessage.title, message: errorMessage.message)
            return true
        }
        return false
    }
    
    open func errorMessageForCode(_ code: Int) -> ErrorMessage? {
        if let messages = self.errorMessages {
            for errorMessage in messages {
                if code == errorMessage.forCode {
                    return errorMessage
                }
            }
        }
        return nil
    }
    
    open func notify(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
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
        window.windowLevel = UIWindow.Level.alert
        
        if let rootViewController = window.rootViewController {
            window.makeKeyAndVisible()
            
            rootViewController.present(self, animated: flag, completion: completion)
        }
    }
}
