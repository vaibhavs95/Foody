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
