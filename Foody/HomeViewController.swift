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
            tableview.register(UINib(nibName: String(describing: VenueTableViewCell.self), bundle: nil), forCellReuseIdentifier: String(describing: VenueTableViewCell.self))
            if #available(iOS 10, *) {
                tableview.refreshControl = self.refreshControl
            } else {
                tableview.addSubview(self.refreshControl)
            }
        }
    }

    lazy private var refreshControl: UIRefreshControl = {
        let control = UIRefreshControl()
        control.tintColor = UIColor.brown
        control.attributedTitle = NSAttributedString(string: "Fetching Venues", attributes: [NSAttributedStringKey.foregroundColor: UIColor.brown])
        control.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        return control
    }()
    lazy private var searchBar: UISearchBar = {
        let searchBar =  UISearchBar(frame: CGRect(x: UIScreen.main.bounds.width - 50, y: 0, width: 0, height: 44))
        searchBar.searchBarStyle = .minimal
        searchBar.showsCancelButton = true
        searchBar.delegate = self
        searchBar.alpha = 0
        return searchBar
    }()
    lazy private var searchButton: UIBarButtonItem = {
        return UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(self.searchButtontapped(_:)))
    }()
    private let locationManager = CLLocationManager()
    private var currentLocation = CLLocationCoordinate2D()
    private var viewModel: HomeViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()

        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()

        let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext
        viewModel = HomeViewModel(context: context)
        viewModel.setup()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        customizeNavBar()
    }

    private func customizeNavBar() {
        navigationItem.rightBarButtonItem = searchButton
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "Recommendations"
    }

    @objc func searchButtontapped(_ sender: UIBarButtonItem) {
        navigationItem.setRightBarButton(nil, animated: true)
        navigationItem.titleView = searchBar

        UIView.animate(withDuration: 0.25, animations: {
            self.searchBar.alpha = 1
            self.searchBar.frame = self.navigationItem.accessibilityFrame
        }, completion: { finished in
            self.searchBar.becomeFirstResponder()
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

    func getRecommendations(at location: CLLocationCoordinate2D) {
        self.showLoader()
        viewModel.fetchRecommended(router: .fetchRecommended(location: location, limit: 15)) { (venues) in
            self.reloadView(with: venues)
        }
    }

    private func reloadView(with venues: [Venue?]) {
        hideLoader()
        refreshControl.endRefreshing()
        tableview.isHidden = false
        tableview.reloadData()
    }

}

extension HomeViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRowsInSection(section: section)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableview.dequeueReusableCell(withIdentifier: String(describing: VenueTableViewCell.self), for: indexPath) as! VenueTableViewCell

        if let itemForCell = viewModel.getItemForCell(at: indexPath) {
            cell.configure(item: itemForCell)
            cell.delegate = self
        }
        cell.selectionStyle = .none

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let id = viewModel.getItemForCell(at: indexPath)?.id {
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
        searchBar.resignFirstResponder()

        UIView.animate(withDuration: 0.25, animations: {
            searchBar.alpha = 0
            searchBar.frame.origin.x = UIScreen.main.bounds.width
        }, completion: { finished in
            self.navigationItem.rightBarButtonItem = self.searchButton
        })
    }
}

extension HomeViewController: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location Manager failed with error : \(error.localizedDescription)")
        locationManager.startUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

        if let newLocation = locations.last, newLocation.timestamp.timeIntervalSinceNow < -30 || newLocation.horizontalAccuracy <= 100 {
            // Invalidate the Location Manager for further updates
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
            self.currentLocation = newLocation.coordinate
            getRecommendations(at: newLocation.coordinate)
        }
    }
}

extension HomeViewController: VenueTableViewCellDelegate {

    func cellDislikeButtonTapped(disliked: Bool, itemWith id: String) {
        viewModel.updateDislikesInData(disliked, at: id)
    }
}
