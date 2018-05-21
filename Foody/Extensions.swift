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

    public convenience init?(hexString: String) {
        let r, g, b, a: CGFloat
        let hexColor = "ff\(hexString)"

        if hexColor.count == 8 {
            let scanner = Scanner(string: hexColor)
            var hexNumber: UInt64 = 0

            if scanner.scanHexInt64(&hexNumber) {
                a = CGFloat((hexNumber & 0xff000000) >> 24) / 255
                r = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
                g = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
                b = CGFloat(hexNumber & 0x000000ff) / 255

                self.init(red: r, green: g, blue: b, alpha: a)
                return
            }
        }

        return nil
    }

    static let tealBlue = UIColor(red: 53/255, green: 92/255, blue: 125/255, alpha: 1)
    static let defaultBlue = UIColor(red: 0, green: 122/255, blue: 1, alpha: 1)
}

extension UIViewController {

    func showLoader() {
        if let existing = view.viewWithTag(100) as? UIActivityIndicatorView {
            existing.removeFromSuperview()
        }
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
