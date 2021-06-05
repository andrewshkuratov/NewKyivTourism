//
//  LocationDetailController.swift
//  NewKyivTourism
//
//  Created by Andrew on 02.06.2021.
//

import Foundation
import MapKit
import WebKit
import FaveButton

class LocationDetailController: UIViewController {
    @IBOutlet weak var locationTitle: UILabel!
    @IBOutlet weak var locationImage: UIImageView!
    @IBOutlet weak var mapPinImage: UIImageView!
    @IBOutlet weak var content: UILabel!
    @IBOutlet weak var adress: UILabel!
    @IBOutlet weak var categoryLabel: PaddingLabel!
    @IBOutlet weak var favouritesButton: FaveButton!
    
    @IBOutlet weak var commentsButton: UIButton!
    @IBOutlet weak var mapButton: UIButton!
        
    var locationInfo: LocationModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
}

extension LocationDetailController {
    func setup() {
        if let info = locationInfo {
            categoryLabel.roundCorner()
            commentsButton.roundView()
            mapButton.roundView()
            locationImage.roundCorner()
                        
            categoryLabel.text = info.category?.title
            locationTitle.text = info.title
            content.text = info.content?.htmlToString
            adress.text = info.location
            
            locationImage.af.setImage(withURL: URL(string: Constants.Network.baseURL + (info.image)!)!)
            
            if let index = info.catId, index < Constants.CategoriesColours.colorSet.count {
                categoryLabel.backgroundColor = Constants.CategoriesColours.colorSet[index - 1]
                mapPinImage.image = Constants.Images.pinsSet[index - 1]
            } else {
                categoryLabel.backgroundColor = Constants.CategoriesColours.colorSet[0]
                mapPinImage.image = Constants.Images.pinsSet[0]
            }
                        
            getFavourites()
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func getFavourites() {
        userIsLoggedInCheck(completion: { (isLogged) in
            if isLogged {
                Network.sendRequest(endpoint: .favourites, data: nil, type: LocationResponse.self) { result in
                    switch result {
                    case .success(let response):
                        self.checkFavourites(response.data)
                        break
                    case .failure(let error):
                        self.loadAlert(error.localizedDescription) {
                            
                        }
                        break
                    }
                }
            }
        })
    }
    
    func checkFavourites(_ favourites: Array<LocationModel>) {
        favouritesButton.tag = locationInfo!.id
        favouritesButton.setSelected(selected:
                                        favourites.contains(where: { (i) -> Bool in
                                            return locationInfo!.id == i.id
                                        }), animated: false)
    }
    
    
    @IBAction func likeAction(_ sender: FaveButton) {
        print("Worked")
        userIsLoggedInCheck { (isLogged) in
            if isLogged {
                if sender.isSelected {
                    let dict = ["place_id" : "\(sender.tag)"]
                    let data = try! JSONEncoder().encode(dict)
                    Network.SendLike(data)
                } else {
                    let dict = ["place_id" : "\(sender.tag)"]
                    let data = try! JSONEncoder().encode(dict)
                    Network.SendDislike(data)
                }
            } else {
                sender.setSelected(selected: false, animated: false)
            }
        }
    }
    
    @IBAction func showMap(_ sender: Any) {
        guard let loc = locationInfo else {
            return
        }
        showLocationMapController(locations: [loc])
    }
    
    @IBAction func showComments(_ sender: Any) {
        guard let loc = locationInfo else {
            return
        }
        showCommentsController(routeId: loc.id, endpoint: Constants.Path.location)
    }
    
    @IBAction func rateButton(_ sender: Any) {
        userIsLoggedInCheck { (isLogged) in
            if isLogged {
                self.ratingAlert(self.locationInfo!.id, Constants.Path.location, title: NSLocalizedString("Please, rate this location",comment: ""))
            } else {
                self.loadAlert("You are not logged in") {
                    
                }
            }
        }
    }
}
