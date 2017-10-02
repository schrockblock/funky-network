// https://github.com/Quick/Quick

import UIKit
import Quick
import Nimble
import OHHTTPStubs
import FunkyNetwork
@testable import FunkyNetwork_Example

class LoginSpec: QuickSpec {
    override func spec() {
        describe("Login test") {
            context("success") {
                it("should log in successfully") {
                    waitUntil(timeout: 0.5) { done in
                        let _ = LoginNetworkCall(configuration: ExampleServerConfiguration.stub, username: "fake73", password: "fakepassword")
                            .login().startWithResult({ (result) in
                                switch result {
                                case let .success(successObject):
                                    expect(successObject).toNot(beNil())
                                    if let success = successObject {
                                        expect(success.objectId).toNot(beNil())
                                        expect(success.apiToken).toNot(beNil())
                                    }
                                    done()
                                    break
                                case .failure(_):
                                    expect(false).to(beTrue())
                                    break
                                }
                            })
                    }
                }
            }
        }
        
        describe("stubbing test") {
            it("should stub only this instance of the call"){
                let unsuccessfulStub = StubHolder(responseCode: 403, stubFileName: "login_fail.json")
                let successfulCall = LoginNetworkCall(configuration: ExampleServerConfiguration.stub, username: "fake73", password: "fakepassword")
                let unsuccessfulCall = LoginNetworkCall(configuration: ExampleServerConfiguration.stub, username: "fake73", password: "fakepassword", stubHolder: unsuccessfulStub)
                
                waitUntil(timeout: 0.5) { done in
                    unsuccessfulCall.login().startWithResult({ (result) in
                        switch result {
                        case .success(_):
                            expect(false).to(beTrue())
                            done()
                            break
                        case let .failure(error):
                            expect(error.code == unsuccessfulStub.responseCode).to(beTrue())
                            break
                        }
                        
                        successfulCall.login().startWithResult({ (result) in
                            switch result {
                            case .success(_):
                                unsuccessfulCall.login().startWithFailed({ _ in
                                    done()
                                })
                                break
                            case .failure(_):
                                expect(false).to(beTrue())
                                done()
                                break
                            }
                        })
                    })
                }
            }
        }
    }
}
