//
//  LoginNetworkCall.swift
//  SBNetworking
//
//  Created by Elliot Schrock on 8/31/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import UIKit
import FunkyNetwork
import Eson
import ReactiveSwift

open class LoginNetworkCall: JsonNetworkCall {
    fileprivate static let usernameKey = "username"
    fileprivate static let passwordKey = "password"
    
    init(username: String, password: String) {
        let json = [LoginNetworkCall.usernameKey: username, LoginNetworkCall.passwordKey: password]
        var postData: Data?
        do {
            postData = try JSONSerialization.data(withJSONObject: json, options: JSONSerialization.WritingOptions.prettyPrinted)
        } catch let parseError as NSError {
            NSLog("Parse error: %@", parseError.localizedDescription);
        }
        
        super.init(configuration: ExampleServerConfiguration.current, httpMethod: "POST", endpoint: "user/auth/local/login", postData: postData)
    }
    
    func login() -> SignalProducer<LoginSuccessObject?, NSError> {
        return super.jsonProducer()
            .flatMap(.concat, parse)
            .flatMapError { error -> SignalProducer<LoginSuccessObject?, NSError> in
                let isHandled = DefaultNetworkErrorHandler.handleError(error: error)
                return SignalProducer(error: error)
            }
    }
    
    func parse(_ json: Any) -> SignalProducer<LoginSuccessObject?, NSError> {
        return SignalProducer(value: json)
            .map { json in
                let responseObject = Eson().fromJsonDictionary(json as? [String : AnyObject], clazz: ResponseObject<LoginSuccessObject>.self)
                return responseObject?.dataObject()
            }
    }
}
