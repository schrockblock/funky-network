//
//  StubbableNetworkCall.swift
//  Pods
//
//  Created by Elliot Schrock on 9/15/17.
//
//

import UIKit
import OHHTTPStubs
import ReactiveSwift

open class StubbableNetworkCall: NetworkCall {
    public let stubHolder: StubHolderProtocol?
    
    public init(configuration: ServerConfigurationProtocol, httpMethod: String, httpHeaders: Dictionary<String, String>?, endpoint: String, postData: Data?, stubHolder: StubHolderProtocol? = nil) {
        self.stubHolder = stubHolder
        
        super.init(configuration: configuration, httpHeaders: httpHeaders, endpoint: endpoint, postData: postData)
    }
    
    open override func producer() -> SignalProducer<Data, NSError> {
        if let stubHolder = self.stubHolder, configuration.shouldStub {
            let stubDesc = stub(condition: stubCondition()) { _ in
                let stubPath = OHPathForFileInBundle(stubHolder.stubFileName, Bundle.main)
                return fixture(filePath: stubPath!, status: stubHolder.responseCode, headers: stubHolder.responseHeaders)
            }
            return super.producer().on(disposed: {
                OHHTTPStubs.removeStub(stubDesc)
            })
        } else {
            return super.producer()
        }
    }
    
    open func stubCondition() -> ((URLRequest) -> Bool) {
        return { $0.url?.absoluteString == self.urlString(self.endpoint) && $0.httpMethod == self.httpMethod }
    }
}
