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

class HomeViewController: UIViewController {

    @IBOutlet weak var tableview: UITableView! {
        didSet {
            tableview.dataSource = self
            tableview.delegate = self
            tableview.rowHeight = UITableViewAutomaticDimension
            tableview.isHidden = true
            if #available(iOS 10, *) {
                tableview.refreshControl = self.refreshControl
            } else {
                tableview.addSubview(self.refreshControl)
            }
            tableview.register(UINib(nibName: String(describing: VenueTableViewCell.self), bundle: nil), forCellReuseIdentifier: String(describing: VenueTableViewCell.self))
        }
    }

    lazy private var refreshControl: UIRefreshControl = {
        let control = UIRefreshControl()
        control.tintColor = UIColor.brown
        control.attributedTitle = NSAttributedString(string: "Fetching Venues", attributes: [NSAttributedStringKey.foregroundColor: UIColor.brown])
        control.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        return control
    }()
    private let context: NSManagedObjectContext? = {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return nil }

        return appDelegate.persistentContainer.viewContext
    }()

    private let locationManager = CLLocationManager()
    private var currentLocation = CLLocationCoordinate2D()
    private var dislikedVenues: [NSManagedObject] = []
    private var venues: [Venue?] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        customizeNavBar()
        fetchDisliked()
    }

    private func customizeNavBar() {
        let backButton = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem = backButton
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

    @objc private func refreshData(_ sender: UIRefreshControl) {
        sender.endRefreshing()
    }

    func search(with query: String, at location: CLLocationCoordinate2D) {
        if let request = Router
                        .search(query: query, location: location)
                        .asUrlRequest() {
            showLoader()

            let dataTask = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
                if error != nil {
                    print("API Unsuccessful : \(String(describing: error?.localizedDescription))")
                } else {
                    let result = NetworkManager.decodeResponse(data: data, type: SearchResponse.self)
                    print(result as Any)
                    self.venues = result?.venues ?? []
                    DispatchQueue.main.async {
                        self.hideLoader()
                        self.tableview.isHidden = false
                        self.tableview.reloadData()
                    }
                }
            })
            dataTask.resume()
        }
    }

    func getRecommendations(at location: CLLocationCoordinate2D, offset: Int = 0 ) {
        let limit = 15 + offset

        if let request = Router
                        .fetchRecommended(location: location, limit: limit)
                        .asUrlRequest() {
            showLoader()

            let dataTask = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
                if error != nil {
                    print("API Unsuccessful : \(String(describing: error?.localizedDescription))")
                } else {
                    let result = self.decodeResponse(data: data, type: RecommendedResponse.self)
                    //Map the response to the Venue Data Type
                    self.venues = result?.groups?.first?.items?.map { return $0.venue } ?? []

                    //Filter the response removing the disliked places
                    for disliked in self.dislikedVenues {
                        self.venues = self.venues.filter { $0?.id != (disliked.value(forKey: "id") as! String) }
                    }

                    DispatchQueue.main.async {
                        self.tableview.isHidden = false
                        self.tableview.reloadData()
                        self.hideLoader()
                        self.checkCount(currentOffset: offset)
                    }
                    print(result as Any)
                }
            })
            dataTask.resume()
        }

    }

    private func checkCount(currentOffset: Int) {
        if venues.count < 10 {
            getRecommendations(at: currentLocation, offset: currentOffset + 10)
        }
    }

     private func decodeResponse<T: Codable>(data: Data?, type: T.Type, decoder: JSONDecoder = JSONDecoder()) -> T? {
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

    func saveDisliked(_ id: String) {
        guard let managedContext = context else { return }
        let entity = NSEntityDescription.entity(forEntityName: "ManagedVenue", in: managedContext)!
        let person = NSManagedObject(entity: entity, insertInto: managedContext)
        person.setValue(id, forKey: "id")

        saveDBState(context: managedContext)
    }

    func fetchDisliked() {
        guard let managedContext = context else { return }
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "ManagedVenue")
        do {
            dislikedVenues = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }

    func saveDBState(context: NSManagedObjectContext) {
        do {
            try context.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
}

extension HomeViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return venues.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableview.dequeueReusableCell(withIdentifier: String(describing: VenueTableViewCell.self), for: indexPath) as! VenueTableViewCell
        guard let itemForCell = venues[indexPath.row]

            else { return cell }
        cell.configure(item: itemForCell)
        cell.delegate = self
        cell.selectionStyle = .none

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let id = self.venues[indexPath.row]?.id {
            let detailsVc = DetailsViewController(venueId: id)
            navigationController?.pushViewController(detailsVc, animated: true)
        }
    }
}

extension HomeViewController: UISearchBarDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let query = searchBar.text {
            searchBar.resignFirstResponder()
            self.search(with: query, at: self.currentLocation)
        }
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

extension HomeViewController: CLLocationManagerDelegate {

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

            self.currentLocation = newLocation.coordinate
            getRecommendations(at: newLocation.coordinate)
        }
    }
}

extension HomeViewController: VenueTableViewCellDelegate {

    func cellDislikeButtonTapped(disliked: Bool, itemWith id: String) {
        if let index = venues.index(where: { $0?.id == id }) {
            //Save current state in Data Models
            venues[index]?.isDisliked = disliked
        }

        if disliked {
            //Save in the Database
            saveDisliked(id)

        } else if let managedContext = context {
            //Remove from the database to display again if not disliked
            fetchDisliked()
            if let indexToDelete = dislikedVenues.index(where: { ($0.value(forKey: "id") as! String) == id }) {
                managedContext.delete(dislikedVenues[indexToDelete])
                dislikedVenues.remove(at: indexToDelete)
                saveDBState(context: managedContext)
            }
        }
    }
}
