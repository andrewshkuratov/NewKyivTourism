//
//  RoutesModel.swift
//  NewKyivTourism
//
//  Created by Andrew on 30.05.2021.
//

import Foundation

struct RouteResponse: Codable {
    let success: Bool
    let data: Array<RouteModel>
    let message: String
    
    enum CodingKeys: String, CodingKey {
        case success
        case data
        case message
    }
}

struct RouteModel: Codable {
    let id: Int
    let places: Array<LocationModel>
    let title: String
    let routeCommentsCount: Int?
    let ratingsAvg: String?
    let length: Double?
    
    enum CodingKeys: String, CodingKey {
        case places
        case title
        case id
        case routeCommentsCount = "routecomments_count"
        case ratingsAvg = "ratings_avg"
        case length
    }
}
