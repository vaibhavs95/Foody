//
//  VenueTableViewCell.swift
//  Foody
//
//  Created by Vaibhav Singh on 20/05/18.
//  Copyright © 2018 Vaibhav. All rights reserved.
//

import UIKit

class VenueTableViewCell: UITableViewCell {

    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var dislikeButton: UIButton! {
        didSet {
            dislikeButton.layer.cornerRadius = 15
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

    func configure(item: GroupItem) {
        nameLabel.text = item.venue?.name
        distanceLabel.text = "\(item.venue?.location?.distance ?? 0) metres"
        categoryLabel.text = item.venue?.categories?.first?.name
        if let reason = item.reasons?.items?.first.unsafelyUnwrapped?.summary {
            categoryLabel.text?.append(", \(reason)")
        }
        addressLabel.text = item.venue?.location?.formattedAddress?.joined()
    }
    
    @IBAction func dislikeButtonTapped(_ sender: Any) {

    }
}
