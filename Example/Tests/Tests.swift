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
                                                .login().map { successObject -> Bool in
                                                    expect(successObject).toNot(beNil())
                                                    if let success = successObject {
                                                        expect(success.objectId).toNot(beNil())
                                                        expect(success.apiToken).toNot(beNil())
                                                    }
                                                    done()
                                                    return true
                                                }.start()
                    }
                }
            }
        }
    }
}
