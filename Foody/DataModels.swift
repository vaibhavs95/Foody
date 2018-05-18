//
//  DataModels.swift
//  Foody
//
//  Created by Vaibhav Singh on 19/05/18.
//  Copyright © 2018 Vaibhav. All rights reserved.
//

import Foundation

struct FoursquareResponse<T>: Codable where T: Codable {

    var meta: MetaData?
    var response: T?

    enum CodingKeys: String, CodingKey {

        case meta
        case response
    }
}

struct MetaData: Codable {

    var code: Int?
    var requestId: String?

    enum CodingKeys: String, CodingKey {
        case code
        case requestId
    }
}

struct Warning: Codable {

    var text: String?

    enum CodingKeys: String, CodingKey {
        case text
    }
}

struct Response: Codable {

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
    var distance: Int?
    var postalCode: String?
    var city:  String?
    var state: String?
    var country: String?
    var formattedAddress: [String]?

    enum CodingKeys: String, CodingKey {
        case address
        case countryCode = "cc"
        case street = "crossStreet"
        case distance
        case postalCode
        case city
        case state
        case country
        case formattedAddress
    }
}

struct Category: Codable {

    var id: String?
    var name: String?
    var icon: Icon?

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case icon
    }
}

struct Icon: Codable {

    var prefix: String?
    var suffix: String?

    enum CodingKeys: String, CodingKey {
        case prefix
        case suffix
    }
}
