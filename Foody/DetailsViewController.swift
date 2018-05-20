//
//  DetailsViewController.swift
//  Foody
//
//  Created by Vaibhav Singh on 20/05/18.
//  Copyright © 2018 Vaibhav. All rights reserved.
//

import UIKit
import Kingfisher

class DetailsViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView! {
        didSet {
            scrollView.setContentOffset(CGPoint(x: 0, y: scrollView.contentOffset.y), animated: true)
        }
    }
    @IBOutlet weak var imageView: UIImageView! {
        didSet {
            imageView.layer.masksToBounds = true
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

    convenience init(venueId: String) {
        self.init()

        self.venueId = venueId
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        getDetails(id: venueId)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.navigationBar.prefersLargeTitles = false
    }

    private func getDetails(id: String) {
        let endPoint = "https://api.foursquare.com/v2/venues/\(id)?v=\(foursquare_version)&client_id=\(client_id)&client_secret=\(client_secret)"

        if let url = URL(string: endPoint) {
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")

            showLoader()

            let dataTask = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
                if error != nil {
                    print("API Unsuccessful : \(String(describing: error?.localizedDescription))")
                } else {
                     let result = self.decodeResponse(data: data, type: VenueDetailResponse.self)
                    print(result as Any)

                    DispatchQueue.main.async {
                        self.hideLoader()
                        self.details = result?.details
                        self.configureView(with: result?.details)
                    }
                }
            })
            dataTask.resume()
        }
    }

    private func configureView(with venue: VenueDetails?) {

        navigationItem.title = venue?.name

        imageView.kf.setImage(with: venue?.bestPhoto?.photoUrl)
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
}
