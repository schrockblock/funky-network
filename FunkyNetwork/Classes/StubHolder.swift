//
//  StubHolder.swift
//  Pods
//
//  Created by Elliot Schrock on 9/15/17.
//
//

import UIKit

public protocol StubHolderProtocol {
    var responseCode: Int32 { get }
    var stubFileName: String { get }
    var responseHeaders: [String: String] { get }
}

open class StubHolder: StubHolderProtocol {
    public let responseCode: Int32
    public let stubFileName: String
    public let responseHeaders: [String : String]
    
    public init(responseCode: Int32 = 200, stubFileName: String, responseHeaders: [String: String] = ["Content-type":"application/json"]) {
        self.responseCode = responseCode
        self.stubFileName = stubFileName
        self.responseHeaders = responseHeaders
    }
}
