//
//  ExampleServerConfiguration.swift
//  FunkyNetwork
//
//  Created by Elliot Schrock on 8/31/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import UIKit
import FunkyNetwork

open class ExampleServerConfiguration: ServerConfiguration {
    public static let production = ServerConfiguration(scheme: "https", host: "habitica.com", apiRoute: "api/v1")
    public static let staging = ServerConfiguration(scheme: "https", host: "staging.habitica.com", apiRoute: "api/v1")
    public static let dev = ServerConfiguration(scheme: "http", host: "localhost", apiRoute: "api/v1")
    public static let stub = ServerConfiguration(shouldStub: true, scheme: "https", host: "habitica.com", apiRoute: "api/v1")
    
    public static let current = production
}
