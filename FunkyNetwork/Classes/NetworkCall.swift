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
    
    public init(configuration: ServerConfigurationProtocol, httpMethod: String = "GET", httpHeaders: Dictionary<String, String>?, endpoint: String, postData: Data?) {
        self.configuration = configuration
        self.httpMethod = httpMethod
        self.httpHeaders = httpHeaders
        self.endpoint = endpoint
        self.postData = postData
    }
    
    open func producer() -> SignalProducer<Data, NSError> {
        return SignalProducer { observer, disposable in
            let session = URLSession(configuration: URLSessionConfiguration.default, delegate: nil, delegateQueue: OperationQueue.main)
            let request = self.mutableRequest()
            let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
                if let connectionError = error as NSError? {
                    observer.send(error: connectionError)
                } else if let responseCode = (response as? HTTPURLResponse)?.statusCode {
                    if let data = data, responseCode < 300 {
                        observer.send(value: data)
                        observer.sendCompleted()
                    } else {
                        let url = request.url?.absoluteString ?? ""
                        let serverError = NSError(domain: "Server", code: responseCode, userInfo: ["url" : url])
                        observer.send(error: serverError)
                    }
                }
            }
            disposable.observeEnded(task.cancel)
            task.resume()
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
