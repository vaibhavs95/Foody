//
//  ViewController.swift
//  Foody
//
//  Created by Vaibhav Singh on 18/05/18.
//  Copyright © 2018 Vaibhav. All rights reserved.
//

import UIKit
import CoreLocation
import CoreData

let client_id = "RR4Q04VMOJ0FTEHABY2BRPTBAEDERHYVUQB5XQVGTUUNODII"
let client_secret = "N4V0SWGFY5MYEVWOHQGYB5AOOEBVOPWTTEEULM1YDFB1T0JQ"
let foursquare_version = "20180519"

class ViewController: UIViewController {

    let locationManager = CLLocationManager()
    var storedVenues: [ManagedVenue] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        customizeNavBar()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        fetch()
    }

    private func customizeNavBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "Recommendations"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(searchButtontapped(_:)))
    }

    @objc func searchButtontapped(_ sender: UIBarButtonItem) {
        navigationItem.setRightBarButton(nil, animated: true)

        let searchBar = UISearchBar(frame: CGRect(x: UIScreen.main.bounds.width - 50, y: 0, width: 0, height: 44))
        searchBar.searchBarStyle = .minimal
        searchBar.showsCancelButton = true
        searchBar.delegate = self
        searchBar.alpha = 0

        navigationItem.titleView = searchBar
        UIView.animate(withDuration: 0.25, animations: {
            searchBar.alpha = 1
            searchBar.frame = self.navigationItem.accessibilityFrame
        }, completion: { finished in
            searchBar.becomeFirstResponder()
        })
    }

    func snapToPlace(location: CLLocationCoordinate2D) {
//        let endPoint = "https://api.foursquare.com/v2/venues/explore?ll=\(location.latitude),\(location.longitude)&v=\(foursquare_version)&intent=checkin&limit=25&radius=5000&section=food&client_id=\(client_id)&client_secret=\(client_secret)"

         let endPoint = "https://api.foursquare.com/v2/venues/search?ll=\(location.latitude),\(location.longitude)&v=\(foursquare_version)&intent=checkin&query=restaurant&limit=20&radius=5000&client_id=\(client_id)&client_secret=\(client_secret)"

        if let url = URL(string: endPoint) {
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")

            let dataTask = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
                if error != nil {
                    print("API Unsuccessful : \(String(describing: error?.localizedDescription))")
                } else {
                    let result = self.decodeResponse(data: data, type: SearchResponse.self)
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

    func save(id: String) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }

        let managedContext = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "ManagedVenue", in: managedContext)!
        let person = NSManagedObject(entity: entity, insertInto: managedContext)
        person.setValue(id, forKey: "id")

        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }

    func fetch() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }

        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<ManagedVenue>(entityName: "ManagedVenue")
        do {
            storedVenues = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
}

extension ViewController: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location Manager failed with error : \(error.localizedDescription)")
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let newLocation = locations.last, newLocation.timestamp.timeIntervalSinceNow < -30 || newLocation.horizontalAccuracy <= 100 {

            // Invalidate the Location Manager for further updates
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil

            print(newLocation.coordinate.latitude)
            print(newLocation.coordinate.longitude)

            snapToPlace(location: newLocation.coordinate)
        }
    }
}

extension ViewController: UISearchBarDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // Todo: Call the seach API
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {

        UIView.animate(withDuration: 0.25, animations: {
            searchBar.alpha = 0
            searchBar.frame.origin.x = UIScreen.main.bounds.width
        }, completion: { finished in
            searchBar.resignFirstResponder()
            self.navigationItem.titleView = nil
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(self.searchButtontapped(_:)))
        })
    }
}
