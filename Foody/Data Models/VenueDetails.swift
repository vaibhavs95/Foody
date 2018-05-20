//
//  VenueDetails.swift
//  Foody
//
//  Created by Vaibhav Singh on 20/05/18.
//  Copyright © 2018 Vaibhav. All rights reserved.
//

import Foundation

struct VenueDetailResponse: Codable {

    var details: VenueDetails?

    enum CodingKeys: String, CodingKey {

        case details = "response"
    }
}

struct VenueDetails: Codable {

    var id: String?
    var name: String?
    var contact: Contact?
    var location: Location?
    var cetegories: [Category]?
    var likes: Likes?
    var rating: Double?
    var ratingColor: String?
    var description: String?
    var hours: Availability?
    var verified: Bool?
    var bestPhoto: Photo?

    enum CodingKeys: String, CodingKey {

        case id
        case name
        case contact
        case location
        case cetegories
        case likes
        case rating
        case ratingColor
        case description
        case hours
        case verified
        case bestPhoto
    }
}

struct Contact: Codable {

    var phone: String?
    var formattedPhone: String?
    var twitter: String?
    var instagram: String?
    var facebook: String?

    enum CodingKeys: String, CodingKey {

        case phone
        case formattedPhone
        case twitter
        case instagram
        case facebook = "facebookUsername"
    }
}

struct Likes: Codable {

    var likes: Int?
    var summary: String?

    enum CodingKeys: String, CodingKey {
        case likes
        case summary
    }
}

struct Availability: Codable {

    var status: String?
    var isOpen: Bool?
    var isLocalHoliday: Bool?

    enum CodingKeys: String, CodingKey {
        case status
        case isOpen
        case isLocalHoliday
    }

}

