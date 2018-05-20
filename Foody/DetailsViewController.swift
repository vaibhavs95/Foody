//
//  DetailsViewController.swift
//  Foody
//
//  Created by Vaibhav Singh on 20/05/18.
//  Copyright © 2018 Vaibhav. All rights reserved.
//

import UIKit
import Kingfisher
import MapKit

class DetailsViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var scrollView: UIScrollView! {
        didSet {
            scrollView.setContentOffset(CGPoint(x: 0, y: scrollView.contentOffset.y), animated: true)
        }
    }
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel! {
        didSet {
            ratingLabel.layer.cornerRadius = 10
            ratingLabel.layer.masksToBounds = true
        }
    }
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var availabilityLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var verifiedLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var likesLabel: UILabel!
    @IBOutlet weak var contactLabel: UILabel!
    @IBOutlet weak var twitterLabel: UILabel!
    @IBOutlet weak var instagramLabel: UILabel!
    @IBOutlet weak var facebookLabel: UILabel!

    private var venueId = String()
    private var details: VenueDetails?
    private var viewModel: DetailViewModel!

    convenience init(venueId: String) {
        self.init()

        self.venueId = venueId
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel = DetailViewModel(id: self.venueId)
        setup(id: venueId)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.navigationBar.prefersLargeTitles = false
        let directionsBarButton = UIBarButtonItem(title: "Get Directions", style: .plain, target: self, action: #selector(getDirections))
        navigationItem.rightBarButtonItem = directionsBarButton
    }

    @objc func getDirections() {
        let loc = mapView.annotations.first as! MapPin
        let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeWalking]
        loc.mapItem().openInMaps(launchOptions: launchOptions)
    }

    private func setup(id: String) {
        showLoader()
        viewModel.fetchDetails(router: .fetchDetails(id: id)) { (details) in
            DispatchQueue.main.async {
                self.hideLoader()
                self.details = details
                self.configureView(with: details)
                self.configureMaps()
            }
        }
    }

    private func configureMaps() {
        guard let lattitude = details?.location?.lattitude, let longitude = details?.location?.longitude else { return }

        let location = CLLocationCoordinate2D(latitude: lattitude, longitude: longitude)
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location, 2500, 2500)
        mapView.setRegion(coordinateRegion, animated: true)
        mapView.addAnnotation(MapPin(title: details?.name, foursquareId: venueId, coordinate: location))
    }

    private func configureView(with venue: VenueDetails?) {

        title = venue?.name

        nameLabel.text = venue?.name
        ratingLabel.text = "  \(venue?.rating ?? 0.0)  "
        ratingLabel.backgroundColor = UIColor(hexString: venue?.ratingColor ?? "000000") ?? UIColor.black
        addressLabel.text = venue?.location?.formattedAddress?.joined(separator: ", ")
        let availability = venue?.hours?.isOpen ?? false
        availabilityLabel.text = availability ? "Open now" : "Closed"
        availabilityLabel.textColor = availability ? UIColor.defaultBlue : UIColor.red
        statusLabel.text = " • \(venue?.hours?.status ?? "Availability not Available ;D")"
        categoryLabel.text = venue?.cetegories?.first?.name

        let optionalFields = [ (descriptionLabel, venue?.description),
                               (distanceLabel, venue?.location?.distance),
                               (verifiedLabel, venue?.verified),
                               (likesLabel, venue?.likes?.likes),
                               (contactLabel, venue?.contact?.phone),
                               (twitterLabel, venue?.contact?.twitterHandle),
                               (instagramLabel, venue?.contact?.instaHandle),
                               (facebookLabel, venue?.contact?.fbHandle) ] as [(UILabel, Any?)]

        for field in optionalFields {
            if let value = field.1 as? String {
                field.0.text = value
            } else {
                field.0.isHidden = true
            }
        }

    }
}
