//
//  Maps.swift
//  Foody
//
//  Created by Vaibhav Singh on 21/05/18.
//  Copyright © 2018 Vaibhav. All rights reserved.
//

import Foundation
import MapKit

class MapPin: NSObject, MKAnnotation {
    let title: String?
    let foursquareId: String
    let coordinate: CLLocationCoordinate2D

    init(title: String?, foursquareId: String, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.foursquareId = foursquareId
        self.coordinate = coordinate

        super.init()
    }

    func mapItem() -> MKMapItem {
        let placemark = MKPlacemark(coordinate: coordinate)

        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = title

        return mapItem
    }
}

