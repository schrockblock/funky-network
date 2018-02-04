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

open class NetworkCall {
    public let configuration: ServerConfigurationProtocol
    public let endpoint: String
    public let httpMethod: String
    public let postData: Data?
    public let httpHeaders: Dictionary<String, String>?
    
    public let dataTaskSignal: Signal<URLSessionDataTask, NoError>
    public let errorSignal: Signal<NSError, NoError>
    public let serverErrorSignal: Signal<NSError, NoError>
    public let responseSignal: Signal<URLResponse, NoError>
    public let httpResponseSignal: Signal<HTTPURLResponse, NoError>
    public let dataSignal: Signal<Data?, NoError>
    
    let dataTaskProperty = MutableProperty<URLSessionDataTask?>(nil)
    let errorProperty = MutableProperty<NSError?>(nil)
    let serverErrorProperty = MutableProperty<NSError?>(nil)
    let responseProperty = MutableProperty<URLResponse?>(nil)
    let dataProperty = MutableProperty<Data?>(nil)
    
    let fireProperty = MutableProperty(())
    
    public init(configuration: ServerConfigurationProtocol, httpMethod: String = "GET", httpHeaders: Dictionary<String, String>?, endpoint: String, postData: Data?) {
        self.configuration = configuration
        self.httpMethod = httpMethod
        self.httpHeaders = httpHeaders
        self.endpoint = endpoint
        self.postData = postData
        
        dataTaskSignal = dataTaskProperty.signal.skipNil()
        errorSignal = errorProperty.signal.skipNil()
        responseSignal = responseProperty.signal.skipNil()
        httpResponseSignal = responseSignal.map({ $0 as? HTTPURLResponse }).skipNil()
        serverErrorSignal = httpResponseSignal.filter({ $0.statusCode > 300 }).map({ NSError(domain: "Server", code: $0.statusCode, userInfo: ["url" : $0.url?.absoluteString as Any]) })
        dataSignal = dataProperty.signal
        
        dataTaskSignal.observeValues { task in
            task.resume()
        }
    }
    
    open func fire() {
        let session = URLSession(configuration: URLSessionConfiguration.default, delegate: nil, delegateQueue: OperationQueue.main)
        let request = self.mutableRequest()
        dataTaskProperty.value = session.dataTask(with: request as URLRequest) { (data, response, error) in
            self.errorProperty.value = error as NSError?
            self.responseProperty.value = response
            self.dataProperty.value = data
        }
    }
    
    open func mutableRequest() -> NSMutableURLRequest {
        let mutableRequest = NSMutableURLRequest()
        mutableRequest.url = url(endpoint)
        
        if let headers = httpHeaders {
            for key in headers.keys {
                mutableRequest.addValue(headers[key]!, forHTTPHeaderField: key)
            }
        }
        
        mutableRequest.httpMethod = httpMethod
        if httpMethod != "GET" {
            mutableRequest.httpBody = postData
        }
        
        return mutableRequest
    }
    
    open func url(_ endpoint: String) -> URL? {
        return URL(string: urlString(endpoint))
    }
    
    open func urlString(_ endpoint: String) -> String {
        let baseUrlString = "\(configuration.scheme)://\(configuration.host)"
        if let apiRoute = configuration.apiBaseRoute {
            return "\(baseUrlString)/\(apiRoute)/\(endpoint)"
        } else {
            return "\(baseUrlString)/\(endpoint)"
        }
    }
}
