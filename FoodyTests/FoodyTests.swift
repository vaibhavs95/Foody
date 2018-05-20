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
    var homeViewModel: HomeViewModel!

    override func setUp() {
        super.setUp()

        sessionUnderTest = URLSession(configuration: URLSessionConfiguration.default)
        homeViewModel = HomeViewModel(context: (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext)
    }
    
    override func tearDown() {
        sessionUnderTest = nil
        homeViewModel = nil

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

    func testAPICallCompletes () {
        let request = Router.fetchRecommended(location: CLLocationCoordinate2D(latitude: 28.6720616290574, longitude: 77.2859521098061), limit: 20).asUrlRequest()!
        let promise = expectation(description: "Completion handler invoked")
        var statusCode: Int?
        var responseError: Error?

        let dataTask = sessionUnderTest.dataTask(with: request) { (data, response, error) in
            statusCode = (response as? HTTPURLResponse)?.statusCode
            responseError = error
            promise.fulfill()
        }
        dataTask.resume()
        waitForExpectations(timeout: 5, handler: nil)

        XCTAssertNil(responseError)
        XCTAssertEqual(statusCode, 200)
    }

    func testDislikedVenuesDeleted() {
        let dislikedVenues = homeViewModel.fetchDisliked()
        homeViewModel.fetchRecommended(router: .fetchRecommended(location: CLLocationCoordinate2D(latitude: 28.6720616290574, longitude: 77.2859521098061), limit: 20)) { (venues) in
            let randomIndex = Int(arc4random_uniform(UInt32(dislikedVenues.count)))
            let randomId = dislikedVenues[randomIndex].value(forKey: "id") as! String
            let matches = venues.filter { $0?.id == randomId }

            XCTAssertNil(matches)
        }
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
