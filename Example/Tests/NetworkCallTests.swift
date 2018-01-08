import XCTest
import OHHTTPStubs
@testable import FunkyNetwork

class NetworkCallTests: XCTestCase {
    typealias NetCall = NetworkCall
    
    let responseJsonString = "{}"
    static let scheme = "https"
    static let host = "habitica.com"
    static let apiRoute = "api/v1"
    static let endpoint = "tasks"
    let stubConfig = ServerConfiguration(shouldStub: false, scheme: scheme, host: host, apiRoute: apiRoute)
    
    func testCorrectUrl() {
        handleDefaultCall(config: stubConfig, urlString: "https://habitica.com/api/v1/tasks")
    }
    
    func testCorrectUrlScheme() {
        let config = ServerConfiguration(shouldStub: true, scheme: "http", host: NetworkCallTests.host, apiRoute: NetworkCallTests.apiRoute)
        handleDefaultCall(config: config, urlString: "http://habitica.com/api/v1/tasks")
    }
    
    func testCorrectHost() {
        let config = ServerConfiguration(shouldStub: true, scheme: NetworkCallTests.scheme, host: "google.com", apiRoute: NetworkCallTests.apiRoute)
        handleDefaultCall(config: config, urlString: "https://google.com/api/v1/tasks")
    }
    
    func testCorrectApiRoute() {
        let config = ServerConfiguration(shouldStub: true, scheme: NetworkCallTests.scheme, host: NetworkCallTests.host, apiRoute: "api")
        handleDefaultCall(config: config, urlString: "https://habitica.com/api/tasks")
    }
    
    func testGet() {
        handleDefaultCall(method: "GET")
    }
    
    func testPost() {
        handleDefaultCall(method: "POST")
    }
    
    func testPatch() {
        handleDefaultCall(method: "PATCH")
    }
    
    func testPut() {
        handleDefaultCall(method: "PUT")
    }
    
    func testDelete() {
        handleDefaultCall(method: "DELETE")
    }
    
    func testHeaders() {
        handleDefaultCall(headers: ["Content-Type": "application/json"])
        handleDefaultCall(headers: ["Content-Type": "application/json", "Custom-Header": "blah blah blah"])
    }
    
    func handleDefaultCall(headers: Dictionary<String, String>) {
        let call = NetCall(configuration: stubConfig, httpMethod: "GET", httpHeaders: headers, endpoint: NetworkCallTests.endpoint, postData: nil)
        
        let requestHeaders = call.mutableRequest().allHTTPHeaderFields!
        
        let success = requestHeaders == headers
        
        if !success {
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
            
            call.producer().startWithResult({ (result) in
                var res: Bool = false
                switch result {
                case .success(_):
                    res = true
                    break
                case .failure(_):
                    break
                }
                OHHTTPStubs.removeStub(passStubDesc)
                OHHTTPStubs.removeStub(failStubDesc)
                
                XCTAssert(res)
                
                expectation.fulfill()
            })
            
            self.wait(for: [expectation], timeout: 5.0)
        }
    }
    
    func handleDefaultCall(config: ServerConfiguration, urlString: String) {
        let call = NetCall(configuration: config, httpMethod: "GET", httpHeaders: nil, endpoint: NetworkCallTests.endpoint, postData: nil)
        
        let success = call.mutableRequest().url?.absoluteString == urlString
        
        if !success {
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
            
            call.producer().startWithResult({ (result) in
                var res: Bool = false
                switch result {
                case .success(_):
                    res = true
                    break
                case .failure(_):
                    break
                }
                OHHTTPStubs.removeStub(passStubDesc)
                OHHTTPStubs.removeStub(failStubDesc)
                
                XCTAssert(res)
                
                expectation.fulfill()
            })
            
            self.wait(for: [expectation], timeout: 5.0)
        }
    }
    
    func handleDefaultCall(method: String) {
        let call = NetCall(configuration: stubConfig, httpMethod: method, httpHeaders: nil, endpoint: NetworkCallTests.endpoint, postData: nil)
        
        let success = call.mutableRequest().httpMethod == method
        
        if !success {
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
            
            call.producer().startWithResult({ (result) in
                var res: Bool = false
                switch result {
                case .success(_):
                    res = true
                    break
                case .failure(_):
                    break
                }
                OHHTTPStubs.removeStub(passStubDesc)
                OHHTTPStubs.removeStub(failStubDesc)
                
                XCTAssert(res)
                
                expectation.fulfill()
            })
            
            self.wait(for: [expectation], timeout: 5.0)
        }
    }
}
