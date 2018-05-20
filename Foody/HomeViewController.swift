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
    private var venues: [Venue?] = []
    private var viewModel: HomeViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()

        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()

        viewModel = HomeViewModel(context: context)
        viewModel.setup()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        customizeNavBar()
    }

    private func customizeNavBar() {
        let backButton = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem = backButton
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(searchButtontapped(_:)))
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "Recommendations"
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
        getRecommendations(at: currentLocation)
    }

    func search(with query: String, at location: CLLocationCoordinate2D) {
        self.showLoader()

        viewModel.searchVenues(router: .search(query: query, location: location)) { (venues) in
          self.reloadView(with: venues)
        }
    }

    func getRecommendations(at location: CLLocationCoordinate2D, offset: Int = 0) {
        let limit = 15 + offset

        self.showLoader()
        viewModel.fetchRecommended(router: .fetchRecommended(location: location, limit: limit)) { (venues) in
            self.reloadView(with: venues)
        }
    }

    private func reloadView(with venues: [Venue?]) {
        refreshControl.endRefreshing()
        self.venues = venues
        tableview.isHidden = false
        tableview.reloadData()
        hideLoader()
    }

}

extension HomeViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return venues.count < 10 ? venues.count : 10
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

        viewModel.dislikeButtonTapped(disliked, at: id)
    }
}
