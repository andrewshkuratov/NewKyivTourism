//
//  LocationManagerExtensions.swift
//  NewKyivTourism
//
//  Created by Andrew on 31.05.2021.
//

import Foundation
import CoreLocation

extension CLLocationManager {
    func addRegions(_ locations: Array<LocationModel>) -> Array<CLCircularRegion> {
        var regions: Array<CLCircularRegion> = []
        locations.forEach { (item) in
            let region = CLCircularRegion(center: CLLocationCoordinate2D(latitude: item.latitude, longitude: item.longitude),
                                          radius: 50,
                                          identifier: "\(item.id)")
            region.notifyOnEntry = true
            self.startMonitoring(for: region)
            regions.append(region)
        }
        return regions
    }
}
