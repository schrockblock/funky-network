import PlaygroundSupport
import XCTest
import OHHTTPStubs
@testable import FunkyNetwork

JsonNetworkCallTests.defaultTestSuite.run()
StubbableNetworkCallTests.defaultTestSuite.run()
NetworkCallTests.defaultTestSuite.run()

typealias NetCall = JsonNetworkCall

class JsonNetworkCallTests: XCTestCase {
    let responseJsonString = "{}"
    static let scheme = "https"
    static let host = "habitica.com"
    static let apiRoute = "api/v1"
    static let endpoint = "tasks"
    let stubConfig = ServerConfiguration(shouldStub: true, scheme: scheme, host: host, apiRoute: apiRoute)
    
    func testCustomHeaders() {
        let successfulStub = StubHolder(responseCode: 200, stubData: "{\"success\": true}".data(using: String.Encoding.utf8))
        
        let headers = ["Custom": "header"]
        let call = NetCall(configuration: stubConfig, httpMethod: "PUT", httpHeaders: headers, endpoint: "sessions", postData: responseJsonString.data(using: String.Encoding.utf8), stubHolder: successfulStub)
        
        let requestHeaders = call.mutableRequest().allHTTPHeaderFields!
        
        let success = requestHeaders == ["Custom": "header", "Content-Type": "application/json", "Accept": "application/json"]
        
        if !success {
            boolToString(success)
            XCTAssertTrue(success)
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
            
            call.jsonSignal.observeValues({ json in
                XCTAssertTrue(true)
                var res = true
                
                OHHTTPStubs.removeStub(passStubDesc)
                OHHTTPStubs.removeStub(failStubDesc)
                
                boolToString(res)
                
                XCTAssert(res)
                
                expectation.fulfill()
            })
            call.fire()
            
            self.wait(for: [expectation], timeout: 5.0)
        }
    }
    
    func testHeaders() {
        let successfulStub = StubHolder(responseCode: 200, stubData: "{\"success\": true}".data(using: String.Encoding.utf8))
        let call = NetCall(configuration: stubConfig, httpMethod: "PUT", endpoint: "sessions", postData: responseJsonString.data(using: String.Encoding.utf8), stubHolder: successfulStub)
        
        let headers = ["Content-Type": "application/json", "Accept": "application/json"]
        let requestHeaders = call.mutableRequest().allHTTPHeaderFields!
        
        let success = requestHeaders == headers
        
        if !success {
            boolToString(success)
            XCTAssertTrue(success)
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
            
            call.jsonSignal.observeValues({ json in
                XCTAssertTrue(true)
                var res = true
                
                OHHTTPStubs.removeStub(passStubDesc)
                OHHTTPStubs.removeStub(failStubDesc)
                
                boolToString(res)
                
                XCTAssert(res)
                
                expectation.fulfill()
            })
            call.fire()
            
            self.wait(for: [expectation], timeout: 5.0)
        }
    }
    
    func testJson() {
        let successfulStub = StubHolder(responseCode: 200, stubData: "{\"success\": true}".data(using: String.Encoding.utf8))
        
        handleJsonCall(stubHolder: successfulStub) { (success) in
            boolToString(success)
            
            XCTAssertTrue(success)
        }
    }
    
    func handleJsonCall(stubHolder: StubHolderProtocol, checker: @escaping ((_ success: Bool) -> Void)) {
        let call = NetCall(configuration: stubConfig, httpMethod: "POST", httpHeaders: nil, endpoint: "sessions", postData: "{}".data(using: String.Encoding.utf8), stubHolder: stubHolder)
        
        call.jsonSignal.observeValues { jsonObject in
            let correct = ["success": true]
            var res = false
            if let json = jsonObject as? [String: Bool] {
                res = json == correct
            }
            checker(res)
        }
        call.fire()
    }
}

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
        
        call.httpResponseSignal.observeValues({ response in
            var res = response.statusCode < 300
            checker(res)
        })
        call.fire()
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
        handleDefaultCall(config: config, urlString: "https://habitica.com/api/tasks", checker: { success in
            let result = boolToString(success)
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
//        handleDefaultCall(headers: ["Content-Type": "application/json", "Custom-Header": "blah blah blah"], checker: {
//            success in let result = boolToString(success)
//        })
    }
    
    func handleDefaultCall(headers: Dictionary<String, String>, checker: @escaping ((_ success: Bool) -> Void)) {
        let call = NetCall(configuration: stubConfig, httpMethod: "GET", httpHeaders: headers, endpoint: NetworkCallTests.endpoint, postData: nil)
        
        let requestHeaders = call.mutableRequest().allHTTPHeaderFields!
        
        var success = dictContainsDict(container: requestHeaders, dict: headers)
        
        if !success {
            checker(success)
            XCTAssertTrue(success)
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
            XCTAssertTrue(success)
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
            XCTAssertTrue(success)
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

func dictContainsDict(container: [String: String], dict: [String: String]) -> Bool {
    var success = false
    for (key in dict.allKeys) {
        if let value = container[key] {
            if value == dict[key] {
                success = true
            } else {
                success = false
                break
            }
        } else {
            success = false
            break
        }
    }
    return success
}
