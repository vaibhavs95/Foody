//
//  Extensions.swift
//  Foody
//
//  Created by Vaibhav Singh on 20/05/18.
//  Copyright © 2018 Vaibhav. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {

    static let tealBlue = UIColor(red: 53/255, green: 92/255, blue: 125/255, alpha: 1)
    static let defaultBlue = UIColor(red: 0, green: 122/255, blue: 1, alpha: 1)
}

extension UIViewController {

    func showLoader() {
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        activityIndicator.frame = CGRect(origin: view.bounds.origin, size: CGSize(width: 75, height: 75))
        activityIndicator.backgroundColor = UIColor.darkGray
        activityIndicator.layer.cornerRadius = 15
        activityIndicator.center = view.center
        activityIndicator.startAnimating()
        activityIndicator.tag = 100
        view.addSubview(activityIndicator)
    }

    func hideLoader() {
        let activityIndicator = view.viewWithTag(100) as? UIActivityIndicatorView
        activityIndicator?.stopAnimating()
        activityIndicator?.removeFromSuperview()
    }
}
