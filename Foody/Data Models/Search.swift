//
//  Search.swift
//  Foody
//
//  Created by Vaibhav Singh on 19/05/18.
//  Copyright © 2018 Vaibhav. All rights reserved.
//

import Foundation

struct SearchResponse: Codable {

    var venues: [Venue]?

    enum CodingKeys: String, CodingKey {
        case venues
    }
}

