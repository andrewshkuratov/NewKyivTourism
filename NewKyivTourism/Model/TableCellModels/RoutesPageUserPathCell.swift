//
//  RoutesPageUserPathCell.swift
//  NewKyivTourism
//
//  Created by Andrew on 03.06.2021.
//

import Foundation

class RoutesPageUserPathCell: UITableViewCell {
    @IBOutlet weak var locationName: UILabel!
    @IBOutlet weak var locImage: UIImageView!
    @IBOutlet weak var checked: UIImageView!
    
    func setup(item: LocationModel) {        
        if let image = item.image {
            if let url = URL(string: Constants.Network.baseURL + image) {
                locImage.af.setImage(withURL: url)
            } else {
                locImage.image = UIImage(named: "someKyivChurch")
            }
        } else {
            locImage.image = UIImage(named: "someKyivChurch")
        }
        locationName.text = item.title
        
        locImage.roundCorner()
    }
}
