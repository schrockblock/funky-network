//
//  AuthManager.swift
//  FunkyNetwork
//
//  Created by Elliot Schrock on 9/1/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import UIKit

class AuthManager: NSObject {
    fileprivate static let ApiKeyPref = "api_key"
    
    public static func apiKey() -> String? {
        return ""
    }
    
    public static func saveApiKey(apiKey: String?) {
        
    }
}
