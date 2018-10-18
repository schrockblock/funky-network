//
//  LoginNetworkCall.swift
//  FunkyNetwork
//
//  Created by Elliot Schrock on 8/31/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import UIKit
import FunkyNetwork
import ReactiveSwift
import Result

open class LoginNetworkCall: JsonNetworkCall {
    fileprivate static let usernameKey = "username"
    fileprivate static let passwordKey = "password"
    
    public lazy var loginSuccessObjectSignal: Signal<LoginSuccessObject?, NoError> = self.dataSignal.skipNil().map(LoginNetworkCall.parse)
    
    init(configuration: ServerConfigurationProtocol = ExampleServerConfiguration.current, username: String, password: String, stubHolder: StubHolderProtocol? = StubHolder(responseCode: 200, stubFileName: "login_success.json")) {
        let json = [LoginNetworkCall.usernameKey: username, LoginNetworkCall.passwordKey: password]
        let postData: Data? = JsonDataHandler.deserialize(json)
        
        super.init(configuration: configuration,
                   httpMethod: "POST",
                   endpoint: "user/auth/local/login",
                   postData: postData,
                   stubHolder: stubHolder)
    }
    
    static func parse(_ json: Data) -> LoginSuccessObject? {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let responseObject = try? decoder.decode(ResponseObject<LoginSuccessObject>.self, from: json)
        return responseObject?.data
    }
}
