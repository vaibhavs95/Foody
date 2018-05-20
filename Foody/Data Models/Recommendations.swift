//
//  Recommendations.swift
//  Foody
//
//  Created by Vaibhav Singh on 19/05/18.
//  Copyright © 2018 Vaibhav. All rights reserved.
//

import Foundation

struct RecommendedResponse: Codable {

    var warning: Warning?
    var location: String?
    var fullLocation: String?
    var totalResults: Int?
    var groups: [Recommendation]?

    enum CodingKeys: String, CodingKey {

        case warning
        case location = "headerLocation"
        case fullLocation = "headerFullLocation"
        case totalResults
        case groups
    }
}

struct Recommendation: Codable {

    var type: String?
    var items: [GroupItem]?

    enum CodingKeys: String, CodingKey {
        case type
        case items
    }
}

struct GroupItem: Codable {

    var reasons: Reason?
    var venue: Venue?

    enum CodingKeys: String, CodingKey {
        case reasons
        case venue
    }
}

struct Reason: Codable {

    var count: Int?
    var items: [ReasonItem?]?

    enum CodingKeys: String, CodingKey {
        case count
        case items
    }
}

struct ReasonItem: Codable {

    var summary: String?
    var type: String?
    var name: String?

    enum CodingKeys: String, CodingKey {
        case summary
        case type
        case name = "reasonName"
    }
}

struct Venue: Codable {

    var id: String?
    var name: String?
    var location: Location?
    var categories: [Category]?
    var isDisliked: Bool = false

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case location
        case categories
    }
}

struct Location: Codable {

    var address: String?
    var countryCode: String?
    var street: String?
    var distance: Double?
    var postalCode: String?
    var city:  String?
    var state: String?
    var country: String?
    var lattitude: Double?
    var longitude: Double?
    var formattedAddress: [String]?

    var distanceDescription: String? {
        if let distance = distance {

            return distance > 1000 ? "\(distance/1000.0) Kms away" : "\(distance) metres away"
        }

        return nil
    }

    enum CodingKeys: String, CodingKey {
        case address
        case countryCode = "cc"
        case street = "crossStreet"
        case distance
        case postalCode
        case city
        case state
        case country
        case lattitude = "lat"
        case longitude = "lng"
        case formattedAddress
    }
}

struct Category: Codable {

    var id: String?
    var name: String?
    var icon: Photo?

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case icon
    }
}

struct Photo: Codable {

    var width: Int?
    var height: Int?
    var prefix: String?
    var suffix: String?

    var iconUrl: URL? {
        if let pre = prefix, let suf = suffix {

            return URL(string: "\(pre)88\(suf)")
        }
        return nil
    }

    var photoUrl: URL? {
        if let pre = prefix, let suf = suffix {

            return URL(string: "\(pre)\(width ?? 500)x\(height ?? 500)\(suf)")
        }
        return nil
    }

    enum CodingKeys: String, CodingKey {

        case width
        case height
        case prefix
        case suffix
    }
}
