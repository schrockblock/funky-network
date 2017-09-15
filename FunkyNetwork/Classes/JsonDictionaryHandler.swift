//
//  JsonDictionaryHandler.swift
//  Pods
//
//  Created by Elliot Schrock on 9/11/17.
//
//

import UIKit

public protocol JsonHandlerProtocol {
    func fromJson(json: Any?)
}

open class JsonDictionaryHandler: JsonHandlerProtocol {
    public func fromJson(json: Any?) {
        
    }
}
