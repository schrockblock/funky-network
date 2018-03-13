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
                        let call = LoginNetworkCall(configuration: ExampleServerConfiguration.stub, username: "fake73", password: "fakepassword")
                        call.loginSuccessObjectSignal.observeValues({ successObject in
                            expect(successObject).toNot(beNil())
                            if let success = successObject {
                                expect(success.objectId).toNot(beNil())
                                expect(success.apiToken).toNot(beNil())
                            }
                            done()
                        })
                        call.fire()
                    }
                }
            }
            
            context("failure") {
                it("should fail gracefully") {
                    waitUntil(timeout: 0.5) { done in
                        let unsuccessfulStub = StubHolder(responseCode: 403,
                                                          stubFileName: "login_fail.json",
                                                          bundle: Bundle(for: type(of: self)))
                        
                        let call = LoginNetworkCall(configuration: ExampleServerConfiguration.stub, username: "fake73", password: "fakepassword", stubHolder: unsuccessfulStub)
                        call.serverErrorSignal.observeValues({ error in
                            expect(Int32(error.code)).to(equal(unsuccessfulStub.responseCode))
                            done()
                        })
                        call.fire()
                    }
                }
            }
        }
    }
}
