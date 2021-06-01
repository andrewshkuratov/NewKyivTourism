//
//  MainPageModel.swift
//  NewKyivTourism
//
//  Created by Andrew on 30.05.2021.
//

import Foundation

struct MainPageResponse: Codable {
    let success: Bool
    let message: String
    let data: MainPageModel
    
    enum CodingKeys: String, CodingKey {
        case success
        case message
        case data
    }
}

struct MainPageModel: Codable {
    let places: Array<LocationModel>
    let routes: Array<RouteModel>
    let posters: Array<PosterModel>
    
    enum CodingKeys: String, CodingKey {
        case places
        case routes
        case posters
    }
}
