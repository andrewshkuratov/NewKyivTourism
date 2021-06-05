//
//  RoutesPageMapController.swift
//  NewKyivTourism
//
//  Created by Andrew on 03.06.2021.
//

import Foundation
import UIKit
import MapKit

class RoutesPageMapController: UIViewController {
    @IBOutlet weak var mapView: MKMapView!
    var locations: Array<LocationModel> = []
    var userLocation: CLLocationCoordinate2D?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMap()
        loadData()
    }
}

extension RoutesPageMapController: MKMapViewDelegate {
    func setupMap() {
        self.mapView.delegate = self
        self.mapView.showsUserLocation = true
    }
    
    //MARK: load locations data
    func loadData() {
        createSpinnerView {
            Network.sendRequest(endpoint: .location, data: nil, type: LocationResponse.self) { result in
                switch result {
                case .success(let result):
                    self.locations = result.data
                    self.showAnnotations()
                    self.mapView.reloadInputViews()
                    break
                case .failure(let error):
                    self.loadAlert(error.localizedDescription) {
                        
                    }
                    break
                }
            }
        }
    }
    
    private func showAnnotations() {
        locations.forEach { item in
            let annotation = MKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2D(latitude: item.latitude, longitude: item.longitude)
            annotation.title = item.title
            self.mapView.addAnnotation(annotation)
        }
    }
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        guard self.userLocation == nil else {
            return
        }
        self.userLocation = userLocation.coordinate
        mapView.setCenter(userLocation.coordinate, animated: true)
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let loc = locations.first { (item) -> Bool in
            return item.title == view.annotation?.title
        }
        guard let location = loc else { return }
        showLocationController(item: location)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let title = annotation.title!!
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: title)
        let location = locations.first { (item) -> Bool in
            return item.title == title
        }
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: title)
            annotationView?.canShowCallout = true
            var image: UIImage? = nil
            if let index = location?.catId, index < Constants.Images.pinsSet.count {
                image = Constants.Images.pinsSet[index - 1]
            } else {
                image = Constants.Images.pinsSet[0]
            }
            annotationView?.image = image
            annotationView?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        } else {
            annotationView?.annotation = annotation
        }
        
        return annotationView
    }
}
