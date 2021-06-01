//
//  MainPageLocation.swift
//  NewKyivTourism
//
//  Created by Andrew on 01.06.2021.
//

import Foundation
import FaveButton

class MainPageLocationCell: UITableViewCell {
    @IBOutlet weak var locationImage: UIImageView!
    @IBOutlet weak var locationView: UIView!
    @IBOutlet weak var contentsText: UILabel!
    @IBOutlet weak var numberOfComments: UILabel!
    @IBOutlet weak var rateNumber: UILabel!
    @IBOutlet weak var locationName: UILabel!
    @IBOutlet weak var heartButton: FaveButton!
    @IBOutlet weak var adress: UILabel!
    
    func setup(item: LocationModel, favourites: Array<LocationModel>) {
        locationName.roundCorner()
        locationName.text = item.title
        
        contentsText.roundCorner()
        contentsText.text = item.category?.title
        if let index = item.catId, index < Constants.CategoriesColours.colorSet.count {
            contentsText.backgroundColor = Constants.CategoriesColours.colorSet[index - 1]
        } else {
            contentsText.backgroundColor = Constants.CategoriesColours.colorSet[0]
        }
        
        if let image = item.image {
            if let url = URL(string: Constants.Network.baseURL + image) {
                locationImage.af.setImage(withURL: url)
            } else {
                locationImage.image = UIImage(named: "someKyivChurch")
            }
        } else {
            locationImage.image = UIImage(named: "someKyivChurch")
        }
        locationView.makeDarker()
        locationImage.roundCorner()
        
        numberOfComments.text = String(describing: item.commentsCount ?? 0)
        
        adress.text = item.location
        
        if let rate = item.ratingAvg {
            let r = Double(rate) ?? 0
            rateNumber.text = String(format: "%.1f", r)
        } else {
            rateNumber.text = "0"
        }
        
        heartButton.tag = item.id
        heartButton.setSelected(selected:
                                        favourites.contains(where: { (i) -> Bool in
                                            return item.id == i.id
                                        }), animated: false)        
    }
}
