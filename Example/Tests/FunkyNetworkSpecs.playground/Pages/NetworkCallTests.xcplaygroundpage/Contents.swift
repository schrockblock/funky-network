import PlaygroundSupport
import XCTest
import OHHTTPStubs
@testable import FunkyNetwork

typealias NetCall = NetworkCall

class NetworkCallTests: XCTestCase {
    let responseJsonString = "{}"
    static let scheme = "https"
    static let host = "habitica.com"
    static let apiRoute = "api/v1"
    static let endpoint = "tasks"
    let stubConfig = ServerConfiguration(shouldStub: false, scheme: scheme, host: host, apiRoute: apiRoute)
    
    func testCorrectUrl() {
        handleDefaultCall(config: stubConfig, urlString: "https://habitica.com/api/v1/tasks", checker: {
            success in let result = boolToString(success)
        })
    }
    
    func testCorrectUrlScheme() {
        let config = ServerConfiguration(shouldStub: true, scheme: "http", host: NetworkCallTests.host, apiRoute: NetworkCallTests.apiRoute)
        handleDefaultCall(config: config, urlString: "http://habitica.com/api/v1/tasks", checker: {
            success in let result = boolToString(success)
        })
    }
    
    func testCorrectHost() {
        let config = ServerConfiguration(shouldStub: true, scheme: NetworkCallTests.scheme, host: "google.com", apiRoute: NetworkCallTests.apiRoute)
        handleDefaultCall(config: config, urlString: "https://google.com/api/v1/tasks", checker: {
            success in let result = boolToString(success)
        })
    }
    
    func testCorrectApiRoute() {
        let config = ServerConfiguration(shouldStub: true, scheme: NetworkCallTests.scheme, host: NetworkCallTests.host, apiRoute: "api")
        handleDefaultCall(config: config, urlString: "https://habitica.com/api/tasks", checker: {
            success in let result = boolToString(success)
        })
    }
    
    func testGet() {
        handleDefaultCall(method: "GET", checker: {
            success in let result = boolToString(success)
        })
    }
    
    func testPost() {
        handleDefaultCall(method: "POST", checker: {
            success in let result = boolToString(success)
        })
    }
    
    func testPatch() {
        handleDefaultCall(method: "PATCH", checker: {
            success in let result = boolToString(success)
        })
    }
    
    func testPut() {
        handleDefaultCall(method: "PUT", checker: {
            success in let result = boolToString(success)
        })
    }
    
    func testDelete() {
        handleDefaultCall(method: "DELETE", checker: {
            success in let result = boolToString(success)
        })
    }
    
    func testHeaders() {
        handleDefaultCall(headers: ["Content-Type": "application/json"], checker: {
            success in let result = boolToString(success)
        })
        handleDefaultCall(headers: ["Content-Type": "application/json", "Custom-Header": "blah blah blah"], checker: {
            success in let result = boolToString(success)
        })
    }
    
    func testServerError() {
        let expectation = XCTestExpectation(description: "")
        
        let call = NetCall(configuration: stubConfig, httpMethod: "GET", httpHeaders: ["Content-Type": "application/json"], endpoint: NetworkCallTests.endpoint, postData: nil)
        
        let failStubCondition: ((URLRequest) -> Bool) = {
            $0.url?.absoluteString == call.urlString(call.endpoint)
        }
        let failStubDesc = stub(condition: failStubCondition) { _ in
            let stubData = "{}".data(using: String.Encoding.utf8)
            return OHHTTPStubsResponse(data: stubData!, statusCode:403, headers:nil)
        }
        
        call.serverErrorSignal.observeValues { error in
            boolToString(Int32(error.code) == 403)
            OHHTTPStubs.removeStub(failStubDesc)
            expectation.fulfill()
        }
        
        call.fire()
        
        self.wait(for: [expectation], timeout: 5.0)
    }
    
    func handleDefaultCall(headers: Dictionary<String, String>, checker: @escaping ((_ success: Bool) -> Void)) {
        let call = NetCall(configuration: stubConfig, httpMethod: "GET", httpHeaders: headers, endpoint: NetworkCallTests.endpoint, postData: nil)
        
        let requestHeaders = call.mutableRequest().allHTTPHeaderFields!
        
        let success = requestHeaders == headers
        
        if !success {
            checker(success)
            XCTAssert(success)
        } else {
            let passStubCondition: ((URLRequest) -> Bool) = {
                $0.url?.absoluteString == call.urlString(call.endpoint) && $0.allHTTPHeaderFields! == headers
            }
            let passStubDesc = stub(condition: passStubCondition) { _ in
                let stubData = "{}".data(using: String.Encoding.utf8)
                return OHHTTPStubsResponse(data: stubData!, statusCode:200, headers:nil)
            }
            let failStubCondition: ((URLRequest) -> Bool) = {
                $0.url?.absoluteString == call.urlString(call.endpoint) && $0.allHTTPHeaderFields! != headers
            }
            let failStubDesc = stub(condition: failStubCondition) { _ in
                let stubData = "{}".data(using: String.Encoding.utf8)
                return OHHTTPStubsResponse(data: stubData!, statusCode:403, headers:nil)
            }
            
            let expectation = XCTestExpectation(description: "")
            
            call.responseSignal.observeValues({ (result) in
                var res: Bool = true
                
                OHHTTPStubs.removeStub(passStubDesc)
                OHHTTPStubs.removeStub(failStubDesc)
                
                checker(res)
                
                expectation.fulfill()
            })
            call.fire()
            
            self.wait(for: [expectation], timeout: 5.0)
        }
    }
    
    func handleDefaultCall(config: ServerConfiguration, urlString: String, checker: @escaping ((_ success: Bool) -> Void)) {
        let call = NetCall(configuration: config, httpMethod: "GET", httpHeaders: nil, endpoint: NetworkCallTests.endpoint, postData: nil)
        
        let success = call.mutableRequest().url?.absoluteString == urlString
        
        if !success {
            checker(success)
            XCTAssert(success)
        } else {
            let passStubCondition: ((URLRequest) -> Bool) = {
                $0.url?.absoluteString == call.urlString(call.endpoint)
            }
            let passStubDesc = stub(condition: passStubCondition) { _ in
                let stubData = "{}".data(using: String.Encoding.utf8)
                return OHHTTPStubsResponse(data: stubData!, statusCode:200, headers:nil)
            }
            let failStubCondition: ((URLRequest) -> Bool) = {
                $0.url?.absoluteString != call.urlString(call.endpoint)
            }
            let failStubDesc = stub(condition: failStubCondition) { _ in
                let stubData = "{}".data(using: String.Encoding.utf8)
                return OHHTTPStubsResponse(data: stubData!, statusCode:403, headers:nil)
            }
            
            let expectation = XCTestExpectation(description: "")
            
            call.responseSignal.observeValues({ (result) in
                var res: Bool = true
                
                OHHTTPStubs.removeStub(passStubDesc)
                OHHTTPStubs.removeStub(failStubDesc)
                
                checker(res)
                
                expectation.fulfill()
            })
            call.fire()
            
            self.wait(for: [expectation], timeout: 5.0)
        }
    }
    
    func handleDefaultCall(method: String, checker: @escaping ((_ success: Bool) -> Void)) {
        let call = NetCall(configuration: stubConfig, httpMethod: method, httpHeaders: nil, endpoint: NetworkCallTests.endpoint, postData: nil)
        
        let success = call.mutableRequest().httpMethod == method
        
        if !success {
            checker(success)
            XCTAssert(success)
        } else {
            let passStubCondition: ((URLRequest) -> Bool) = {
                $0.url?.absoluteString == call.urlString(call.endpoint) && $0.httpMethod == method
            }
            let passStubDesc = stub(condition: passStubCondition) { _ in
                let stubData = "{}".data(using: String.Encoding.utf8)
                return OHHTTPStubsResponse(data: stubData!, statusCode:200, headers:nil)
            }
            let failStubCondition: ((URLRequest) -> Bool) = {
                $0.url?.absoluteString == call.urlString(call.endpoint) && $0.httpMethod != method
            }
            let failStubDesc = stub(condition: failStubCondition) { _ in
                let stubData = "{}".data(using: String.Encoding.utf8)
                return OHHTTPStubsResponse(data: stubData!, statusCode:403, headers:nil)
            }
            
            let expectation = XCTestExpectation(description: "")
            
            call.responseSignal.observeValues({ (result) in
                var res: Bool = true
                
                OHHTTPStubs.removeStub(passStubDesc)
                OHHTTPStubs.removeStub(failStubDesc)
                
                checker(res)
                
                expectation.fulfill()
            })
            call.fire()
            
            self.wait(for: [expectation], timeout: 5.0)
        }
    }
}

func boolToString(_ success: Bool) -> String {
    return success ? "✅" : "❌"
}

NetworkCallTests.defaultTestSuite.run()
