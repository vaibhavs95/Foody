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

    let locationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()

        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
    }
}

extension ViewController: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location Manager failed : \(error.localizedDescription)")
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let newLocation = locations.last
        print(newLocation?.coordinate.latitude as Any)
    }

}
