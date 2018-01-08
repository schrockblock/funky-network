import PlaygroundSupport
import XCTest
import OHHTTPStubs
@testable import FunkyNetwork

StubbableNetworkCallTests.defaultTestSuite.run()
NetworkCallTests.defaultTestSuite.run()

typealias NetCall = StubbableNetworkCall

class StubbableNetworkCallTests: XCTestCase {
    let responseJsonString = "{}"
    static let scheme = "https"
    static let host = "habitica.com"
    static let apiRoute = "api/v1"
    static let endpoint = "tasks"
    let stubConfig = ServerConfiguration(shouldStub: true, scheme: scheme, host: host, apiRoute: apiRoute)
    
    func testStubbing() {
        let unsuccessfulStub = StubHolder(responseCode: 500, stubData: "{}".data(using: String.Encoding.utf8))
        
        handleStubbableCall(stubHolder: unsuccessfulStub) { (unSuccess) in
            boolToString(unSuccess)
        }
    }
    
    func testRemovesStubAfterwards() {
        let successfulStub = StubHolder(responseCode: 200, stubData: "{}".data(using: String.Encoding.utf8))
        let unsuccessfulStub = StubHolder(responseCode: 500, stubData: "{}".data(using: String.Encoding.utf8))
        
        handleStubbableCall(stubHolder: unsuccessfulStub) { (unSuccess) in
            boolToString(!unSuccess)
            
            XCTAssert(!unSuccess)
            
            self.handleStubbableCall(stubHolder: successfulStub, checker: { (success) in
                boolToString(success)
                
                XCTAssert(success)
                
                self.handleStubbableCall(stubHolder: unsuccessfulStub, checker: { (unUnSuccess) in
                    boolToString(!unUnSuccess)
                    
                    XCTAssert(!unUnSuccess)
                })
            })
        }
    }
    
    func handleStubbableCall(stubHolder: StubHolderProtocol, checker: @escaping ((_ success: Bool) -> Void)) {
        let call = NetCall(configuration: stubConfig, httpMethod: "POST", httpHeaders: nil, endpoint: "sessions", postData: "{}".data(using: String.Encoding.utf8), stubHolder: stubHolder)
        
        call.producer().startWithResult({ (result) in
            var res = false
            switch result {
            case .success(_):
                res = true
                break
            case let .failure(error):
                break
            }
            
            checker(res)
        })
    }
}

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
            
            call.producer().startWithResult({ (result) in
                var res: Bool = false
                switch result {
                case .success(_):
                    XCTAssert(true)
                    res = true
                    break
                case .failure(_):
                    XCTAssert(false)
                    break
                }
                OHHTTPStubs.removeStub(passStubDesc)
                OHHTTPStubs.removeStub(failStubDesc)
                
                checker(res)
                
                expectation.fulfill()
            })
            
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
            
            call.producer().startWithResult({ (result) in
                var res: Bool = false
                switch result {
                case .success(_):
                    XCTAssert(true)
                    res = true
                    break
                case .failure(_):
                    XCTAssert(false)
                    break
                }
                OHHTTPStubs.removeStub(passStubDesc)
                OHHTTPStubs.removeStub(failStubDesc)
                
                checker(res)
                
                expectation.fulfill()
            })
            
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
            
            call.producer().startWithResult({ (result) in
                var res: Bool = false
                switch result {
                case .success(_):
                    XCTAssert(true)
                    res = true
                    break
                case .failure(_):
                    XCTAssert(false)
                    break
                }
                OHHTTPStubs.removeStub(passStubDesc)
                OHHTTPStubs.removeStub(failStubDesc)
                
                checker(res)
                
                expectation.fulfill()
            })
            
            self.wait(for: [expectation], timeout: 5.0)
        }
    }
}

func boolToString(_ success: Bool) -> String {
    return success ? "✅" : "❌"
}
