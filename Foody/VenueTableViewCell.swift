//
//  VenueTableViewCell.swift
//  Foody
//
//  Created by Vaibhav Singh on 20/05/18.
//  Copyright © 2018 Vaibhav. All rights reserved.
//

import UIKit
import Kingfisher

protocol VenueTableViewCellDelegate: class {
    func cellDislikeButtonTapped(disliked: Bool, itemWith id: String)
}

class VenueTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView! {
        didSet {
            iconImageView.backgroundColor = UIColor.tealBlue
            iconImageView.layer.cornerRadius = 10
        }
    }
    @IBOutlet weak var dislikeButton: UIButton! {
        didSet {
            dislikeButton.layer.borderColor = UIColor.defaultBlue.cgColor
            dislikeButton.layer.borderWidth = 1
            dislikeButton.layer.cornerRadius = dislikeButton.bounds.height / 2
            dislikeButton.clipsToBounds = true
        }
    }
    private var itemId = String()
    private var isDisliked: Bool = false
    weak var delegate: VenueTableViewCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func configure(item: GroupItem) {
        self.itemId = item.venue?.id ?? ""
        nameLabel.text = item.venue?.name
        distanceLabel.text = "\(item.venue?.location?.distance ?? 0) metres away"
        categoryLabel.text = item.venue?.categories?.first?.name
        addressLabel.text = item.venue?.location?.formattedAddress?.joined(separator: ", ")

        if let url = item.venue?.categories?.first?.icon?.url {
            print(url)
            iconImageView.kf.setImage(with: url)
        }
        isDisliked = item.venue?.isDisliked ?? false
        setupButton(isDisliked: item.venue?.isDisliked ?? false)
    }

    fileprivate func setupButton(isDisliked: Bool) {
        let themeColor = isDisliked ? UIColor.red : UIColor.defaultBlue
        dislikeButton.setTitleColor(themeColor, for: .normal)
        dislikeButton.layer.borderColor = themeColor.cgColor
        dislikeButton.tintColor = themeColor
        dislikeButton.setTitle("\(isDisliked ? "Disliked" : "Dislike")", for: .normal)
    }
    
    @IBAction func dislikeButtonTapped(_ sender: Any) {
        isDisliked = !isDisliked
        setupButton(isDisliked: isDisliked)
        delegate?.cellDislikeButtonTapped(disliked: isDisliked, itemWith: itemId)
    }
}
