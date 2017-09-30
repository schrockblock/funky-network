//
//  ResponseObject.swift
//  FunkyNetwork
//
//  Created by Elliot Schrock on 9/1/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import UIKit
import Eson

open class ResponseObject<T: NSObject>: NSObject {
    var success: Bool = false
    var data: [String: AnyObject]?
    
    func dataObject() -> T? {
        return Eson().fromJsonDictionary(data, clazz: T.self)
    }
}
