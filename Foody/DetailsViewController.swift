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


    }

    private func getDetails() {
    }
}
