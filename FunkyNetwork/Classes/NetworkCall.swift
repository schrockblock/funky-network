//
//  NetworkCall.swift
//  Pods
//
//  Created by Elliot Schrock on 9/11/17.
//
//

import UIKit
import ReactiveSwift
import Result
import Prelude

open class NetworkCall {
    public let configuration: ServerConfigurationProtocol
    public let endpoint: String
    public let httpMethod: String
    public let postData: Data?
    public let httpHeaders: [String: String]?
    
    open var requestFromEndpoint: (String) -> NSMutableURLRequest?
    open var configuredRequest: (NSMutableURLRequest?) -> NSMutableURLRequest? = { r in r }
    open var url: (String) -> URL?
    open var urlString: (String) -> String
    
    public let dataTaskSignal: Signal<URLSessionDataTask, NoError>
    
    public let responseSignal: Signal<URLResponse, NoError>
    public let httpResponseSignal: Signal<HTTPURLResponse, NoError>
    public let dataSignal: Signal<Data?, NoError>
    
    public let errorSignal: Signal<NSError, NoError>
    public let serverErrorSignal: Signal<NSError, NoError>
    public let errorDataSignal: Signal<Data, NoError>
    
    let dataTaskProperty = MutableProperty<URLSessionDataTask?>(nil)
    let responseProperty = MutableProperty<URLResponse?>(nil)
    let dataProperty = MutableProperty<Data?>(nil)
    
    let errorProperty = MutableProperty<NSError?>(nil)
    let serverErrorProperty = MutableProperty<NSError?>(nil)
    let errorResponseProperty = MutableProperty<URLResponse?>(nil)
    let errorDataProperty = MutableProperty<Data?>(nil)
    
    let fireProperty = MutableProperty(())
    
    public init(configuration: ServerConfigurationProtocol, httpMethod: String = "GET", httpHeaders: Dictionary<String, String>? = [:], endpoint: String, postData: Data?, networkErrorHandler: NetworkErrorHandler? = nil) {
        self.configuration = configuration
        self.httpMethod = httpMethod
        self.httpHeaders = httpHeaders
        self.endpoint = endpoint
        self.postData = postData
        
        self.urlString = { endpoint in return (configuration |> NetworkCall.configurationToBaseUrlString) + endpoint }
        self.url = URL.init(string:) <<< urlString
        
        dataTaskSignal = dataTaskProperty.signal.skipNil()
        responseSignal = responseProperty.signal.skipNil()
        httpResponseSignal = responseSignal.map({ $0 as? HTTPURLResponse }).skipNil()
        dataSignal = dataProperty.signal
        
        errorDataSignal = errorDataProperty.signal.skipNil()
        if let handler = networkErrorHandler {
            errorSignal = errorProperty.signal.skipNil().filter { !handler.handleError($0) }
            serverErrorSignal = httpResponseSignal.filter({ $0.statusCode > 300 }).map({ NSError(domain: "Server", code: $0.statusCode, userInfo: ["url" : $0.url?.absoluteString as Any]) }).filter { !handler.handleError($0) }
        } else {
            errorSignal = errorProperty.signal.skipNil()
            serverErrorSignal = httpResponseSignal.filter({ $0.statusCode > 300 }).map({ NSError(domain: "Server", code: $0.statusCode, userInfo: ["url" : $0.url?.absoluteString as Any]) })
        }
        
        self.requestFromEndpoint = (self.url <^> NSMutableURLRequest.init(url:))
        self.configuredRequest = applyHeaders >>> applyHttpMethod >>> applyBody
        
        dataTaskSignal.observeValues { task in
            task.resume()
        }
    }
    
    open func fire() {
        let session = URLSession(configuration: configuration.urlConfiguration, delegate: nil, delegateQueue: OperationQueue.main)
        if let request = self.mutableRequest() {
            dataTaskProperty.value = session.dataTask(with: request as URLRequest) { (data, response, error) in
                self.errorProperty.value = error as NSError?
                self.responseProperty.value = response
                if let _ = error {
                    self.errorDataProperty.value = data
                } else if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode > 299 {
                    self.errorDataProperty.value = data
                } else {
                    self.dataProperty.value = data
                }
                session.finishTasksAndInvalidate()
            }
        }
    }
    
    open func mutableRequest() -> NSMutableURLRequest? {
        return endpoint |> (requestFromEndpoint >>> configuredRequest)
    }
    
    public static func configurationToBaseUrlString(_ configuration: ServerConfigurationProtocol) -> String {
        let baseUrlString = "\(configuration.scheme)://\(configuration.host)"
        if let apiRoute = configuration.apiBaseRoute {
            return "\(baseUrlString)/\(apiRoute)/"
        } else {
            return "\(baseUrlString)/"
        }
    }
    
    open func applyHeaders(_ request: NSURLRequest?) -> NSMutableURLRequest? {
        if let mutableRequest = request?.mutableCopy() as? NSMutableURLRequest {
            if let headers = httpHeaders {
                for key in headers.keys {
                    mutableRequest.addValue(headers[key]!, forHTTPHeaderField: key)
                }
            }
            return mutableRequest
        }
        return nil
    }
    
    open func applyHttpMethod(_ request: NSURLRequest?) -> NSMutableURLRequest? {
        if let mutableRequest = request?.mutableCopy() as? NSMutableURLRequest {
            mutableRequest.httpMethod = httpMethod
            return mutableRequest
        }
        return nil
    }
    
    open func applyBody(_ request: NSURLRequest?) -> NSMutableURLRequest? {
        if let mutableRequest = request?.mutableCopy() as? NSMutableURLRequest {
            mutableRequest.httpBody = postData
            return mutableRequest
        }
        return nil
    }
}

precedencegroup ForwardApplication {
    associativity: left
}

infix operator <^>: ForwardApplication

func <^><A, B, C>(f: @escaping (A) -> B?, g: @escaping (B) -> C) -> (A) -> C? {
    return { a in
        if let b = f(a) {
            return g(b)
        } else {
            return nil
        }
    }
}
