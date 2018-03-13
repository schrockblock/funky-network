import XCTest
import OHHTTPStubs
@testable import FunkyNetwork

class StubbableNetworkCallTests: XCTestCase {
    typealias NetCall = StubbableNetworkCall
    
    let responseJsonString = "{}"
    static let scheme = "https"
    static let host = "habitica.com"
    static let apiRoute = "api/v1"
    static let endpoint = "tasks"
    let stubConfig = ServerConfiguration(shouldStub: true, scheme: scheme, host: host, apiRoute: apiRoute)
    
    func testStubbing() {
        let unsuccessfulStub = StubHolder(responseCode: 500, stubData: "{}".data(using: String.Encoding.utf8))
        
        let expectation = XCTestExpectation(description: "")
        handleStubbableCall(stubHolder: unsuccessfulStub, checker: { response in
            XCTAssertEqual(Int32(response.statusCode), unsuccessfulStub.responseCode)
            expectation.fulfill()
        })
        self.wait(for: [expectation], timeout: 5.0)
    }
    
    func testFileStubbing() {
        let stub = StubHolder(responseCode: 500, stubFileName: "login_fail.json", stubData: nil, bundle: Bundle(for: type(of: self)))
        
        let responseExpectation = XCTestExpectation(description: "response")
        let dataExpectation = XCTestExpectation(description: "data")
        let call = NetCall(configuration: stubConfig, httpMethod: "POST", httpHeaders: nil, endpoint: "sessions", postData: "{}".data(using: String.Encoding.utf8), stubHolder: stub)
        call.httpResponseSignal.observeValues({ response in
            XCTAssertEqual(Int32(response.statusCode), stub.responseCode)
            responseExpectation.fulfill()
        })
        call.dataSignal.observeValues { (data) in
            XCTAssertNotNil(data)
            if let data = data {
                if let json = JsonDataHandler.serialize(data) {
                    XCTAssertTrue(json is [String: AnyObject])
                }
            }
            dataExpectation.fulfill()
        }
        call.fire()
        self.wait(for: [dataExpectation, responseExpectation], timeout: 5.0)
    }
    
    func testRemovesStubAfterwards() {
        let errorExpectation = XCTestExpectation(description: "error")
        let successExpectation = XCTestExpectation(description: "server")
        
        let successfulStub = StubHolder(responseCode: 200, stubData: "{}".data(using: String.Encoding.utf8))
        let unsuccessfulStub = StubHolder(responseCode: 500, stubData: "{}".data(using: String.Encoding.utf8))
        
        let failCall = NetCall(configuration: stubConfig, httpMethod: "POST", httpHeaders: nil, endpoint: "sessions", postData: "{}".data(using: String.Encoding.utf8), stubHolder: unsuccessfulStub)
        failCall.serverErrorSignal.observeValues({ serverError in
            XCTAssertEqual(Int32(serverError.code), unsuccessfulStub.responseCode)
            errorExpectation.fulfill()
            
            let successCall = NetCall(configuration: self.stubConfig, httpMethod: "POST", httpHeaders: nil, endpoint: "sessions", postData: "{}".data(using: String.Encoding.utf8), stubHolder: successfulStub)
            successCall.httpResponseSignal.observeValues({ (response) in
                XCTAssertEqual(Int32(response.statusCode), successfulStub.responseCode)
                successExpectation.fulfill()
            })
            successCall.errorSignal.observeValues({ (error) in
                XCTAssertNil(error)
            })
            successCall.fire()
        })
        failCall.fire()
        self.wait(for: [successExpectation, errorExpectation], timeout: 5.0)
    }
    
    func handleStubbableCall(stubHolder: StubHolderProtocol, checker: @escaping ((_ httpResponse: HTTPURLResponse) -> Void)) {
        let call = NetCall(configuration: stubConfig, httpMethod: "POST", httpHeaders: nil, endpoint: "sessions", postData: "{}".data(using: String.Encoding.utf8), stubHolder: stubHolder)
        call.httpResponseSignal.observeValues({ response in
            checker(response)
        })
        call.fire()
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
