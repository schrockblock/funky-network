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

open class JsonNetworkCall: NetworkCall {

    public init(configuration: ServerConfigurationProtocol, httpMethod: String, endpoint: String, postData: Data?) {
        super.init(configuration, httpMethod, JsonNetworkCall.jsonHeaders(), endpoint, postData)
    }
    
    open class func jsonHeaders() -> Dictionary<String, String> {
        return ["Content-type": "application/json", "Accept": "application/json"]
    }
    
    open func jsonProducer() -> SignalProducer<Any, NSError> {
        let scheduler = QueueScheduler(qos: .background, name: "com.kickstarter.ksapi", targeting: nil)
        return super.producer()
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
