//
//  AuthenticatedNetworkCall.swift
//  SBNetworking
//
//  Created by Elliot Schrock on 8/31/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import UIKit
import FunkyNetwork

open class AuthenticatedNetworkCall: JsonNetworkCall {
    fileprivate static let apiKeyHeader = "Auth"
    
    open static override func jsonHeaders() -> Dictionary<String, String> {
        var headers = super.jsonHeaders()
        if let apiKey = AuthManager.apiKey() {
            headers[AuthenticatedNetworkCall.apiKeyHeader] = apiKey
        }
        return headers
    }
}
