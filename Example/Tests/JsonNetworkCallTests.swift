import XCTest
import OHHTTPStubs
@testable import FunkyNetwork

class JsonNetworkCallTests: XCTestCase {
    typealias NetCall = JsonNetworkCall
    
    let responseJsonString = "{}"
    static let scheme = "https"
    static let host = "habitica.com"
    static let apiRoute = "api/v1"
    static let endpoint = "tasks"
    let stubConfig = ServerConfiguration(shouldStub: true, scheme: scheme, host: host, apiRoute: apiRoute)
    
    func testJsonHeaders() {
        let successfulStub = StubHolder(responseCode: 200, stubData: "{\"success\": true}".data(using: String.Encoding.utf8))
        let call = NetCall(configuration: stubConfig, httpMethod: "PUT", endpoint: "sessions", postData: responseJsonString.data(using: String.Encoding.utf8), stubHolder: successfulStub)
        
        let headers = ["Content-Type": "application/json", "Accept": "application/json"]
        var success = false
        if let requestHeaders = call.mutableRequest()?.allHTTPHeaderFields {
            success = dictContainsDict(container: requestHeaders, dict: headers)
        }
        
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
            
            call.jsonSignal.observeValues({ jsonObject in
                OHHTTPStubs.removeStub(passStubDesc)
                OHHTTPStubs.removeStub(failStubDesc)
                
                expectation.fulfill()
            })
            call.fire()
            
            self.wait(for: [expectation], timeout: 5.0)
        }
    }
    
    func testJson() {
        let successfulStub = StubHolder(responseCode: 200, stubData: "{\"success\": true}".data(using: String.Encoding.utf8))
        
        handleJsonCall(stubHolder: successfulStub) { (success) in
            XCTAssert(success)
        }
    }
    
    func handleJsonCall(stubHolder: StubHolderProtocol, checker: @escaping ((_ success: Bool) -> Void)) {
        let call = NetCall(configuration: stubConfig, httpMethod: "POST", httpHeaders: nil, endpoint: "sessions", postData: "{}".data(using: String.Encoding.utf8), stubHolder: stubHolder)
        
        let stubCondition: ((URLRequest) -> Bool) = {
            $0.url?.absoluteString == call.urlString(call.endpoint)
        }
        let stubDesc = stub(condition: stubCondition) { _ in
            let stubData = "{}".data(using: String.Encoding.utf8)
            return OHHTTPStubsResponse(data: stubData!, statusCode:200, headers:nil)
        }
        
        let expectation = XCTestExpectation(description: "")
        
        call.jsonSignal.observeValues({ jsonObject in
            let correct = ["success": true]
            var res = false
            if let json = jsonObject as? [String: Bool] {
                res = json == correct
            }
            
            OHHTTPStubs.removeStub(stubDesc)
            
            checker(res)
            
            expectation.fulfill()
        })
        call.fire()
        
        self.wait(for: [expectation], timeout: 5.0)
    }
    
    func testStubbing() {
        let unsuccessfulStub = StubHolder(responseCode: 500, stubData: "{}".data(using: String.Encoding.utf8))
        
        handleStubbableCall(stubHolder: unsuccessfulStub, checker: { success in
            XCTAssert(!success)
        })
    }
    
    func testRemovesStubAfterwards() {
        let successfulStub = StubHolder(responseCode: 200, stubData: "{}".data(using: String.Encoding.utf8))
        let unsuccessfulStub = StubHolder(responseCode: 500, stubData: "{}".data(using: String.Encoding.utf8))
        
        handleStubbableCall(stubHolder: unsuccessfulStub) { (unSuccess) in
            XCTAssert(!unSuccess)
            
            self.handleStubbableCall(stubHolder: successfulStub, checker: { (success) in
                XCTAssert(success)
                
                self.handleStubbableCall(stubHolder: unsuccessfulStub, checker: { (unUnSuccess) in
                    XCTAssert(!unUnSuccess)
                })
            })
        }
    }
    
    func handleStubbableCall(stubHolder: StubHolderProtocol, checker: @escaping ((_ success: Bool) -> Void)) {
        let call = NetCall(configuration: stubConfig, httpMethod: "POST", httpHeaders: nil, endpoint: "sessions", postData: "{}".data(using: String.Encoding.utf8), stubHolder: stubHolder)
        call.httpResponseSignal.observeValues({ response in
            checker(response.statusCode < 300)
        })
        call.fire()
    }
    
    func testEmptyErrorHandler() {
        let expectation = XCTestExpectation(description: "")
        
        let call = NetCall(configuration: stubConfig, httpMethod: "GET", httpHeaders: ["Content-Type": "application/json"], endpoint: NetworkCallTests.endpoint, postData: nil, networkErrorHandler: FalsyNetworkErrorHandler())
        
        let failStubCondition: ((URLRequest) -> Bool) = {
            $0.url?.absoluteString == call.urlString(call.endpoint)
        }
        let failStubDesc = stub(condition: failStubCondition) { _ in
            let stubData = "{}".data(using: String.Encoding.utf8)
            return OHHTTPStubsResponse(data: stubData!, statusCode:403, headers:nil)
        }
        
        call.serverErrorSignal.observeValues { error in
            XCTAssertEqual(Int32(error.code), 403)
            OHHTTPStubs.removeStub(failStubDesc)
            expectation.fulfill()
        }
        
        call.fire()
        
        self.wait(for: [expectation], timeout: 5.0)
    }
    
    func testFullErrorHandler() {
        let expectation = XCTestExpectation(description: "")
        
        let call = NetCall(configuration: stubConfig, httpMethod: "GET", httpHeaders: ["Content-Type": "application/json"], endpoint: NetworkCallTests.endpoint, postData: nil, networkErrorHandler: TruthyNetworkErrorHandler())
        
        let failStubCondition: ((URLRequest) -> Bool) = {
            $0.url?.absoluteString == call.urlString(call.endpoint)
        }
        let failStubDesc = stub(condition: failStubCondition) { _ in
            let stubData = "{}".data(using: String.Encoding.utf8)
            return OHHTTPStubsResponse(data: stubData!, statusCode:403, headers:nil)
        }
        
        call.serverErrorSignal.observeValues { error in
            XCTAssert(false)
            OHHTTPStubs.removeStub(failStubDesc)
            expectation.fulfill()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)) {
            OHHTTPStubs.removeStub(failStubDesc)
            expectation.fulfill()
        }
        
        call.fire()
        
        self.wait(for: [expectation], timeout: 0.250)
    }
    
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
        handleDefaultCall(headers: ["Custom-Header": "blah blah blah"])
    }
    
    func handleDefaultCall(headers: Dictionary<String, String>) {
        let call = NetCall(configuration: stubConfig, httpMethod: "GET", httpHeaders: headers, endpoint: NetworkCallTests.endpoint, postData: nil)
        
        var success = false
        if let requestHeaders = call.mutableRequest()?.allHTTPHeaderFields {
            success = dictContainsDict(container: requestHeaders, dict: headers)
        }
        
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
            
            call.responseSignal.observeValues({ (result) in
                OHHTTPStubs.removeStub(passStubDesc)
                OHHTTPStubs.removeStub(failStubDesc)
                
                expectation.fulfill()
            })
            call.fire()
            
            self.wait(for: [expectation], timeout: 5.0)
        }
    }
    
    func handleDefaultCall(config: ServerConfiguration, urlString: String) {
        let call = NetCall(configuration: config, httpMethod: "GET", httpHeaders: nil, endpoint: NetworkCallTests.endpoint, postData: nil)
        
        let success = call.mutableRequest()?.url?.absoluteString == urlString
        
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
            
            call.responseSignal.observeValues({ (result) in
                OHHTTPStubs.removeStub(passStubDesc)
                OHHTTPStubs.removeStub(failStubDesc)
                
                expectation.fulfill()
            })
            call.fire()
            
            self.wait(for: [expectation], timeout: 5.0)
        }
    }
    
    func handleDefaultCall(method: String) {
        let call = NetCall(configuration: stubConfig, httpMethod: method, httpHeaders: nil, endpoint: NetworkCallTests.endpoint, postData: nil)
        
        let success = call.mutableRequest()?.httpMethod == method
        
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
            
            call.responseSignal.observeValues({ (result) in
                OHHTTPStubs.removeStub(passStubDesc)
                OHHTTPStubs.removeStub(failStubDesc)
                
                expectation.fulfill()
            })
            call.fire()
            
            self.wait(for: [expectation], timeout: 5.0)
        }
    }
}

func dictContainsDict(container: [String: String], dict: [String: String]) -> Bool {
    var success = false
    
    for key in dict.keys {
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
