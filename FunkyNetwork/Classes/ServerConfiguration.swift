//
//  ServerConfiguration.swift
//  Pods
//
//  Created by Elliot Schrock on 9/11/17.
//
//

import UIKit
import ReactiveSwift

public protocol ServerConfigurationProtocol {
    var scheme: String { get }
    var host: String { get }
    var apiBaseRoute: String? { get }
}

open class ServerConfiguration: ServerConfigurationProtocol {
    public let scheme: String
    public let host: String
    public let apiBaseRoute: String?
    
    public init(scheme: String, host: String, apiRoute: String?) {
        self.scheme = scheme
        self.host = host
        self.apiBaseRoute = apiRoute
    }
}
