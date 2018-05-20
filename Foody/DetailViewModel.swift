//
//  DetailsViewModel.swift
//  Foody
//
//  Created by Vaibhav Singh on 20/05/18.
//  Copyright © 2018 Vaibhav. All rights reserved.
//

import Foundation

class DetailViewModel: NSObject {

    private var venueId: String!

    convenience init(id: String) {
        self.init()

        self.venueId = id
    }

    func fetchDetails(router: Router, completionHanlder: @escaping ((VenueDetails?) -> ())) {
        if let request = router.asUrlRequest() {

            let dataTask = NetworkManager.createTask(request: request, type: VenueDetailResponse.self, completion: { (response) in
                completionHanlder(response?.details)
            })
            dataTask.resume()
        }
    }
}
