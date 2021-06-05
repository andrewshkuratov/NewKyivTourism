//
//  MainPageRouteCell.swift
//  NewKyivTourism
//
//  Created by Andrew on 01.06.2021.
//

import Foundation

class MainPageRouteCell: UICollectionViewCell {
    @IBOutlet weak var locationImage: UIImageView!
    @IBOutlet weak var locationView: UIView!
    @IBOutlet weak var contentsText: UILabel!
    @IBOutlet weak var numberOfComments: UILabel!
    @IBOutlet weak var rateNumber: UILabel!
    @IBOutlet weak var locationName: UILabel!
    @IBOutlet weak var locationDescription: UILabel!
    @IBOutlet weak var page: UILabel!
    
    func setup(_ item: RouteModel, _ index: Int, _ pageText: String) {
        locationName.roundCorner()
        
        locationName.text = item.title

        contentsText.roundCorner()

        contentsText.text = String(format: "%.2f", item.length ?? 0) + " " + NSLocalizedString("km", comment: "")
        
        if let image = item.places.first?.image {
            if let url = URL(string: Constants.Network.baseURL + image) {
                locationImage.af.setImage(withURL: url)
            } else {
                locationImage.image = UIImage(named: Constants.Images.imageSet1[index])
            }
        } else {
            locationImage.image = UIImage(named: Constants.Images.imageSet1[index])
        }
        locationImage.roundCorner()
        
        locationView.makeDarker()
        
        numberOfComments.text = String(describing: item.routeCommentsCount ?? 0)
        
        if let rate = item.ratingsAvg {
            let r = Double(rate) ?? 0
            rateNumber.text = String(format: "%.1f", r)
        } else {
            rateNumber.text = "0"
        }
        
        locationDescription.text = item.title
        
        page.text = pageText
    }
}
