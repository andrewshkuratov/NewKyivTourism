//
//  PathController.swift
//  NewKyivTourism
//
//  Created by Andrew on 30.05.2021.
//

import Foundation
import CoreLocation
import SwiftyJSON
import MapKit

class PathController: UIViewController {
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var timeLabel: UILabel!
    var isUpdating = false
    
    let saveAchievements: AchievementsServer = AchievementsServer()
    let mapSupport: MapSupport = MapSupport()
    
    var locations: Array<LocationModel> = []
    var routeId = 0
    
    let locationManager = CLLocationManager()

    var origin: CLLocationCoordinate2D? = nil
    var path: Array<CLLocationCoordinate2D> = []

    var started = false
    
    var regions: Array<CLCircularRegion> = []
    
    var timer: TimerView = TimerView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard CLLocationManager.locationServicesEnabled() else {
            print("Disabled")
            return
        }
        self.setupController()
    }
    
    override func willMove(toParent parent: UIViewController?) {
        super.willMove(toParent: parent)
        if started {
            saveAchievements.saveDistance(calculateDistance())
        }
        regions.forEach { (item) in
            locationManager.stopMonitoring(for: item)
        }
    }
    
    deinit {
        print(#line, #file)
        locationManager.stopUpdatingLocation()
    }
    
    func sortLocations(currentLocation: CLLocationCoordinate2D) {
        
    }
    
    func userNotLoggedInAction() {
        
    }
}

extension PathController {
    func setupController() {
        setupLocation()
        if self.routeId != -1 {
            self.regions = self.locationManager.addRegions(self.locations)
        }
        setupMap()
    }
    
    func setupLocation() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
    }
    
    func setupMap() {
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
    }
    
    @IBAction func startRoute(_ sender: Any) {
        userIsLoggedInCheck { isLogged in
            if isLogged {
                if self.started {
                    self.navigationController?.popViewController(animated: true)
                } else {
                    self.timer.runTimer(label: self.timeLabel)
                    self.startButton.setTitle(NSLocalizedString("Stop", comment: ""), for: .normal)
                    self.changeStartStatus()
                    self.saveUserRoute()
                    self.isUpdating = true
                }
            }
        }
    }
    
    @IBAction func changeDirection(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            mapSupport.buildPath(from: origin!, locations: locations, mapView: mapView, transport: .walking)
        } else {
            mapSupport.buildPath(from: origin!, locations: locations, mapView: mapView, transport: .automobile)
        }
    }
    
    private func saveUserRoute() {
        if routeId == 0 {
            routeId = saveAchievements.createRoute(locations)
        }
    }
    
    func calculateDistance() -> Double {
        if !path.isEmpty {
            var totalKilometers: CLLocationDistance = 0
            for i in 0..<path.count - 1 {
                let loc1 = path[i]
                let loc2 = path[i + 1]
                totalKilometers += distance(from: loc1, to: loc2)
            }
            return totalKilometers / 1000
        }
        return 0
    }
    
    private func distance(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) -> CLLocationDistance {
        let from = CLLocation(latitude: from.latitude, longitude: from.longitude)
        let to = CLLocation(latitude: to.latitude, longitude: to.longitude)
        return from.distance(from: to)
    }
    
    private func changeStartStatus() {
        started = !started
    }
}

extension PathController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(polyline: overlay as! MKPolyline)
        renderer.strokeColor = Constants.CategoriesColours.colorSet[Int.random(in: 0...3)]
        renderer.lineWidth = 2
        return renderer
    }
}

//MARK: Map view functions
extension PathController: CLLocationManagerDelegate {
    //Custom pins use
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let latitude = annotation.coordinate.latitude
        let longitide = annotation.coordinate.longitude
        
        let location = locations.first { loc in
            return loc.longitude == longitide && loc.latitude == latitude
        }
        
        let identifier = location?.title ?? ""
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.canShowCallout = true
            var image: UIImage? = nil
            if let index = location?.catId, index < Constants.Images.pinsSet.count {
                image = Constants.Images.pinsSet[index - 1]
            } else {
                image = Constants.Images.pinsSet[0]
            }
            annotationView?.image = image
        } else {
            annotationView?.annotation = annotation
        }
        
        return annotationView
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = manager.location?.coordinate else { return }
        if self.origin == nil {
            self.origin = location
            sortLocations(currentLocation: location)
            mapSupport.buildPath(from: location, locations: self.locations, mapView: mapView, transport: .walking)
        }
        path.append(location)
        if isUpdating {
            mapView.setCenter(location, animated: true)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        if routeId != -1 {
            saveAchievements.savePlace(Int(region.identifier)!)
        }
        
        self.regions.removeAll { (item) -> Bool in
            return region.identifier == item.identifier
        }
        
        locationManager.stopMonitoring(for: region)
        
        if String(describing: region.identifier) == String(describing: locations.last?.id ?? 0) {
            if routeId != -1 {
                saveAchievements.saveRoute(routeId)
            }
            self.navigationController?.popViewController(animated: true)
        }
    }
}
