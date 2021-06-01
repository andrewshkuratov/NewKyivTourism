//
//  MainPagePosterCell.swift
//  NewKyivTourism
//
//  Created by Andrew on 01.06.2021.
//

import Foundation

class MainPagePosterCell: UITableViewCell {
    @IBOutlet weak var posterImage: UIImageView!
    @IBOutlet weak var contents: UILabel!
    @IBOutlet weak var location: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var price: UILabel!
    
    func setup(item: PosterModel) {
        name.text = item.title
        location.text = item.location
        date.text = "\(item.date)"
        if let url = URL(string: Constants.Network.baseURL + item.image) {
            posterImage.af.setImage(withURL: url)
        } else {
            posterImage.image = UIImage(named: "someKyivChurch")
        }
        
        contents.layer.masksToBounds = true
        contents.layer.cornerRadius = 5
        
        contents.text = "МИСТЕЦТВО"
        
        price.text = NSLocalizedString("Price", comment: "") +
            ": " +
            "\(item.price ?? 0) " +
            NSLocalizedString("UAH", comment: "")
    }
}
