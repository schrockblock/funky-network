//
//  JsonNetworkCall.swift
//  Pods
//
//  Created by Elliot Schrock on 9/11/17.
//
//

import UIKit
import ReactiveSwift
import Result

open class JsonNetworkCall: StubbableNetworkCall {
    public var jsonSignal: Signal<Any, NoError> {
        return dataSignal.skipNil().map(JsonDataHandler.serialize)
    }

    public override init(configuration: ServerConfigurationProtocol, httpMethod: String, httpHeaders: Dictionary<String, String>? = JsonNetworkCall.jsonHeaders(), endpoint: String, postData: Data?,
                         stubHolder: StubHolderProtocol? = nil) {
        super.init(configuration: configuration, httpMethod: httpMethod, httpHeaders: httpHeaders, endpoint: endpoint, postData: postData, stubHolder: stubHolder)
    }
    
    open class func jsonHeaders() -> Dictionary<String, String> {
        return ["Content-Type": "application/json", "Accept": "application/json"]
    }
}
