//
//  FoodyTests.swift
//  FoodyTests
//
//  Created by Vaibhav Singh on 21/05/18.
//  Copyright © 2018 Vaibhav. All rights reserved.
//

import XCTest
import CoreLocation
@testable import Foody

class FoodyTests: XCTestCase {

    var sessionUnderTest: URLSession!

    override func setUp() {
        super.setUp()

        sessionUnderTest = URLSession(configuration: URLSessionConfiguration.default)
    }
    
    override func tearDown() {
        sessionUnderTest = nil

        super.tearDown()
    }

    func testAPICallGetsHTTPStatusCode200 () {
        let request = Router.fetchRecommended(location: CLLocationCoordinate2D(latitude: 28.6720616290574, longitude: 77.2859521098061), limit: 20).asUrlRequest()!
        let promise = expectation(description: "Status code: 200")

        let dataTask = sessionUnderTest.dataTask(with: request) { (data, response, error) in
            if let error = error {
                XCTFail("Error: \(error.localizedDescription)")
                return
            } else if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                if statusCode == 200 {
                    promise.fulfill()
                } else {
                    XCTFail("Status code: \(statusCode)")
                }
            }
        }
        dataTask.resume()
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
