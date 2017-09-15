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
                    stub(condition: isHost("habitica.com")) { _ in
                        let stubPath = OHPathForFileInBundle("login_success.json", Bundle.main)
                        return fixture(filePath: stubPath!, headers: ["Content-Type":"application/json"])
                    }
                    waitUntil(timeout: 0.5) { done in
                        let username = "fake73"
                        let password = "fakepassword"
                        
                        let _ = LoginNetworkCall(username: username, password: password)
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
