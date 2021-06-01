//
//  MapSupport.swift
//  NewKyivTourism
//
//  Created by Andrew on 31.05.2021.
//

import Foundation
import MapKit

class MapSupport {
    func buildPath(from origin: CLLocationCoordinate2D, locations: Array<LocationModel>, mapView: MKMapView, transport: MKDirectionsTransportType) {
        if !mapView.overlays.isEmpty {
            print("Removed")
            mapView.removeOverlays(mapView.overlays)
        } else {
            print("DidNotRemoved")
        }
        
        var locs: Array<LocationModel> = []
        let category = CategoryModel(id: 0, slug: "", title: "")
        let or = LocationModel(id: 0, catId: 0, title: "Origin", content: "", location: "", latitude: origin.latitude, longitude: origin.longitude, image: "", ratingAvg: "", category: category, commentsCount: 0)
        locs.append(or)
        locations.forEach { location in
            locs.append(location)
        }
        
        // 3.
        var placemarks: Array<MKPlacemark> = []
        locs.forEach { location in
            let placemark = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude))
            placemarks.append(placemark)
        }
        
        // 4.
        var mapItems: Array<MKMapItem> = []
        for placemark in placemarks {
            let mapItem = MKMapItem(placemark: placemark)
            mapItems.append(mapItem)
        }
        
        addPoint(locations: locs, placemarks: placemarks, mapView: mapView)
        
        // 7.
        let directionRequest = MKDirections.Request()
        for i in 0..<mapItems.count {
            if (i + 1) == mapItems.count {
                break
            }
            directionRequest.source = mapItems[i]
            directionRequest.destination = mapItems[i + 1]
            directionRequest.transportType = transport
            directionRequest.requestsAlternateRoutes = false
            
            // Calculate the direction
            let directions = MKDirections(request: directionRequest)
            
            // 8.
            directions.calculate { (response, error) -> Void in
                guard let response = response else {
                    if let error = error {
                        print("Error: \(error)")
                    }
                    return
                }
                        
                let route = response.routes[0]
                mapView.addOverlay((route.polyline), level: MKOverlayLevel.aboveRoads)
                        
                let rect = route.polyline.boundingMapRect
                mapView.setRegion(MKCoordinateRegion(rect), animated: true)
            }
        }
    }
    
    private func addPoint(locations: Array<LocationModel>, placemarks: Array<MKPlacemark>, mapView: MKMapView) {
        var annotations: Array<MKPointAnnotation> = []
        for i in 0..<locations.count {
            let sourceAnnotation = MKPointAnnotation()
            sourceAnnotation.title = locations[i].title
            if let loc = placemarks[i].location {
                sourceAnnotation.coordinate = loc.coordinate
            }
            
            annotations.append(sourceAnnotation)
        }

        mapView.showAnnotations(annotations, animated: true )
    }
}
