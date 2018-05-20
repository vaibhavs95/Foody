//
//  NetworkManager.swift
//  Foody
//
//  Created by Vaibhav Singh on 20/05/18.
//  Copyright © 2018 Vaibhav. All rights reserved.
//

import Foundation
import CoreLocation

let client_id = "RR4Q04VMOJ0FTEHABY2BRPTBAEDERHYVUQB5XQVGTUUNODII"
let client_secret = "N4V0SWGFY5MYEVWOHQGYB5AOOEBVOPWTTEEULM1YDFB1T0JQ"
let foursquare_version = "20180519"

enum Router {

    case search(query: String, location: CLLocationCoordinate2D)
    case fetchRecommended(location: CLLocationCoordinate2D, limit: Int)
    case fetchDetails(id: String)

    var endPoint: URL? {
        switch self {
        case .search(let query, let location):
            return URL(string: "https://api.foursquare.com/v2/venues/search?ll=\(location.latitude),\(location.longitude)&v=\(foursquare_version)&intent=checkin&query=\(query)&limit=20&radius=5000&client_id=\(client_id)&client_secret=\(client_secret)")
        case .fetchRecommended(let location, let limit):
            return URL(string: "https://api.foursquare.com/v2/venues/explore?ll=\(location.latitude),\(location.longitude)&v=\(foursquare_version)&intent=checkin&limit=\(limit)&radius=5000&section=food&client_id=\(client_id)&client_secret=\(client_secret)")
        case .fetchDetails(let id):
            return URL(string: "https://api.foursquare.com/v2/venues/\(id)?v=\(foursquare_version)&client_id=\(client_id)&client_secret=\(client_secret)")
        }
    }
}

extension URLRequest {

    mutating func authorize() {
        httpMethod = "GET"
        addValue("application/json", forHTTPHeaderField: "Content-Type")
        addValue("application/json", forHTTPHeaderField: "Accept")
    }
}

struct NetworkManager {

    static func decodeResponse<T: Codable>(data: Data?, type: T.Type, decoder: JSONDecoder = JSONDecoder()) -> T? {
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
