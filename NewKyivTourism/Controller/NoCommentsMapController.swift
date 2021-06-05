//
//  NoCommentsMapController.swift
//  NewKyivTourism
//
//  Created by Andrew on 03.06.2021.
//

import Foundation
import CoreLocation

class NoCommentsMapController: PathController {
    @IBOutlet weak var mapButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.mapButton.roundView()
    }
    
    override func sortLocations(currentLocation: CLLocationCoordinate2D) {
        locations = locations.sorted() {
            CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude).distance(from: currentLocation) <
                CLLocationCoordinate2D(latitude: $0.latitude, longitude: $1.longitude).distance(from: currentLocation)
        }
    }
}
