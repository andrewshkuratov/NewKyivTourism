//
//  PosterDetailController.swift
//  NewKyivTourism
//
//  Created by Andrew on 03.06.2021.
//

import Foundation

class PosterDetailController: UIViewController {
    @IBOutlet weak var posterTitle: UILabel!
    @IBOutlet weak var posterImage: UIImageView!
    @IBOutlet weak var content: UILabel!
    @IBOutlet weak var adress: UILabel!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var learnMoreButton: UIButton!
    @IBOutlet weak var mapButton: UIButton!
    @IBOutlet weak var categoryLabel: PaddingLabel!
    
    var posterCategory = ""
    var posterData: PosterModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
}

extension PosterDetailController {
    func setup() {
        categoryLabel.layer.masksToBounds = true
        categoryLabel.layer.cornerRadius = 5
                
        if let data = posterData {
            posterTitle.text = data.title
            adress.text = data.location
            posterImage.af.setImage(withURL: URL(string: Constants.Network.baseURL + data.image)!)
            content.text = data.content
            categoryLabel.text = "МИСТЕЦТВО"
            price.text = NSLocalizedString("Price", comment: "") +
                ": " +
                "\(data.price ?? 0) " +
                NSLocalizedString("UAH", comment: "")
            
            learnMoreButton.setTitle(NSLocalizedString("Learn more", comment: ""), for: .normal)
            learnMoreButton.roundView()
            mapButton.roundView()
        }
    }
    
    @IBAction func onSite(_ sender: Any) {
        if let url = posterData?.url {
            UIApplication.shared.open(URL(string: url)!)
        }
    }
    
    @IBAction func onMap(_ sender: Any) {
        let locations = [LocationModel(id: 0, catId: nil, title: "", content: nil, location: nil, latitude: posterData!.latitude, longitude: posterData!.longitude, image: nil, ratingAvg: nil, category: nil, commentsCount: 0)]
        showLocationMapController(locations: locations)
    }
}
