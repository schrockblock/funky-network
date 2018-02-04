//
//  AuthenticatedNetworkCall.swift
//  FunkyNetwork
//
//  Created by Elliot Schrock on 8/31/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import UIKit
import FunkyNetwork

open class AuthenticatedNetworkCall: JsonNetworkCall {
    fileprivate static let apiKeyHeader = "Auth"
    
    public override init(configuration: ServerConfigurationProtocol, httpMethod: String, httpHeaders: Dictionary<String, String>?, endpoint: String, postData: Data?, stubHolder: StubHolderProtocol?) {
        super.init(configuration: configuration, httpMethod: httpMethod, httpHeaders: AuthenticatedNetworkCall.jsonHeaders(), endpoint: endpoint, postData: postData, stubHolder: stubHolder)
    }
    
    open static override func jsonHeaders() -> Dictionary<String, String> {
        var headers = super.jsonHeaders()
        if let apiKey = AuthManager.apiKey() {
            headers[AuthenticatedNetworkCall.apiKeyHeader] = apiKey
        }
        return headers
    }
}
