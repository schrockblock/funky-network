//
//  LoginNetworkCall.swift
//  FunkyNetwork
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
    
    init(configuration: ServerConfigurationProtocol = ExampleServerConfiguration.current, username: String, password: String, stubHolder: StubHolderProtocol? = StubHolder(responseCode: 200, stubFileName: "login_success.json")) {
        let json = [LoginNetworkCall.usernameKey: username, LoginNetworkCall.passwordKey: password]
        let postData: Data? = JsonDataHandler.deserialize(json)
        
        super.init(configuration: configuration, httpMethod: "POST", endpoint: "user/auth/local/login", postData: postData, stubHolder: stubHolder)
    }
    
    func login() -> SignalProducer<LoginSuccessObject?, NSError> {
        return jsonProducer()
            .flatMap(.concat, parse)
            .flatMapError { error -> SignalProducer<LoginSuccessObject?, NSError> in
                let isHandled = DefaultNetworkErrorHandler.handleError(error: error)
                if !isHandled {
                    // handle error however you'd like
                }
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
