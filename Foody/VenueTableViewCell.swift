//
//  VenueTableViewCell.swift
//  Foody
//
//  Created by Vaibhav Singh on 20/05/18.
//  Copyright © 2018 Vaibhav. All rights reserved.
//

import UIKit
import Kingfisher

class VenueTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView! {
        didSet {
            iconImageView.backgroundColor = UIColor(red: 53/255, green: 92/255, blue: 125/255, alpha: 1)
            iconImageView.layer.cornerRadius = 10
        }
    }
    @IBOutlet weak var dislikeButton: UIButton! {
        didSet {
            dislikeButton.layer.borderColor = UIColor(red: 0, green: 122/255, blue: 1, alpha: 1).cgColor
            dislikeButton.layer.borderWidth = 1
            dislikeButton.layer.cornerRadius = dislikeButton.bounds.height / 2
            dislikeButton.clipsToBounds = true
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
        distanceLabel.text = "\(item.venue?.location?.distance ?? 0) metres away"
        categoryLabel.text = item.venue?.categories?.first?.name
        addressLabel.text = item.venue?.location?.formattedAddress?.joined(separator: ", ")
        if let url = item.venue?.categories?.first?.icon?.url {
            print(url)
            iconImageView.kf.setImage(with: url)
        }
    }
    
    @IBAction func dislikeButtonTapped(_ sender: Any) {

    }
}
