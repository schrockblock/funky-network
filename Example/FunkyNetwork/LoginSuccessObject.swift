//
//  LoginSuccessObject.swift
//  FunkyNetwork
//
//  Created by Elliot Schrock on 9/1/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import UIKit

open class LoginSuccessObject: ServerObject, Decodable {
    var newUser: Bool = false
    var apiToken: String?
}
