//
//  ServerObject.swift
//  SBNetworking
//
//  Created by Elliot Schrock on 9/1/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import UIKit
import Eson

open class ServerObject: NSObject, EsonKeyMapper {
    var objectId: NSNumber?
    
    open static func esonPropertyNameToKeyMap() -> [String : String] {
        return ["objectId":"id"]
    }
}
