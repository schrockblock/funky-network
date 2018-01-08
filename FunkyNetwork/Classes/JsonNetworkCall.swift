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

    public override init(configuration: ServerConfigurationProtocol, httpMethod: String, httpHeaders: Dictionary<String, String>? = JsonNetworkCall.jsonHeaders(), endpoint: String, postData: Data?, stubHolder: StubHolderProtocol? = nil) {
        super.init(configuration: configuration, httpMethod: httpMethod, httpHeaders: httpHeaders, endpoint: endpoint, postData: postData, stubHolder: stubHolder)
    }
    
    open class func jsonHeaders() -> Dictionary<String, String> {
        return ["Content-Type": "application/json", "Accept": "application/json"]
    }
    
    open func jsonProducer() -> SignalProducer<Any, NSError> {
        let scheduler = QueueScheduler(qos: .background, name: "com.networking.funky", targeting: nil)
        return producer()
            .start(on: scheduler)
            .map(JsonDataHandler.serialize)
            .flatMap(.concat) { json -> SignalProducer<Any, NSError> in
                guard let json = json else {
                    return SignalProducer(error: NSError())
                }
                return SignalProducer(value: json)
            }
    }
}
