//
//  ViewController.swift
//  Foody
//
//  Created by Vaibhav Singh on 18/05/18.
//  Copyright © 2018 Vaibhav. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController {

    let client_id = "RR4Q04VMOJ0FTEHABY2BRPTBAEDERHYVUQB5XQVGTUUNODII"
    let client_secret = "N4V0SWGFY5MYEVWOHQGYB5AOOEBVOPWTTEEULM1YDFB1T0JQ"
    let foursquare_version = "20180519"
    let locationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()

        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
    }

    func snapToPlace(location: CLLocationCoordinate2D) {
        let endPoint = "https://api.foursquare.com/v2/venues/explore?ll=\(location.latitude),\(location.longitude)&v=\(foursquare_version)&intent=checkin&limit=1&radius=4000&client_id=\(client_id)&client_secret=\(client_secret)"

        if let url = URL(string: endPoint) {
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")

            let dataTask = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
                if error != nil {
                    print("API Unsuccessful : \(String(describing: error?.localizedDescription))")
                } else {
                    let result = self.decodeResponse(data: data, type: Response.self)
                    print(result as Any)
                }
            })
            dataTask.resume()
        }

    }

    func decodeResponse<T: Codable>(data: Data?, type: T.Type, decoder: JSONDecoder = JSONDecoder()) -> T? {
        do {
            if let data = data {
                let response = try decoder.decode(FoursquareResponse<T>.self, from: data)
                return response.response
            }
        } catch let error {
            print("Error while decoding -> \(error.localizedDescription)")
        }
        return nil
    }
}

extension ViewController: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location Manager failed : \(error.localizedDescription)")
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let newLocation = locations.last, newLocation.timestamp.timeIntervalSinceNow < -10, newLocation.horizontalAccuracy < 100 {

            // Invalidate the Location Manager for further updates
            locationManager.startUpdatingLocation()
            locationManager.delegate = nil

            print(newLocation.coordinate.latitude)
            print(newLocation.coordinate.longitude)

            snapToPlace(location: newLocation.coordinate)
        }
    }

}
