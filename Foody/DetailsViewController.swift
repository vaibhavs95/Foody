//
//  DetailsViewController.swift
//  Foody
//
//  Created by Vaibhav Singh on 20/05/18.
//  Copyright © 2018 Vaibhav. All rights reserved.
//

import UIKit

class DetailsViewController: UIViewController {

    private var venueId = String()

    convenience init(venueId: String) {
        self.init()

        self.venueId = venueId
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.prefersLargeTitles = false
        getDetails(id: venueId)
    }

    private func getDetails(id: String) {
        let endPoint = "https://api.foursquare.com/v2/venues/\(id)"
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
                     let result = self.decodeResponse(data: data, type: VenueDetailResponse.self)?.details
                    print(result as Any)
                }
            })
            dataTask.resume()
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
