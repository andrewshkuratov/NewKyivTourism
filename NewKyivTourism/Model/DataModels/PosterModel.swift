//
//  PosterModel.swift
//  NewKyivTourism
//
//  Created by Andrew on 30.05.2021.
//

import Foundation

struct PosterResponse: Codable {
    let success: Bool
    let data: Array<PosterModel>
    let message: String
    
    enum CodingKeys: String, CodingKey {
        case success
        case data
        case message
    }
}

struct PosterModel: Codable {
    let title: String
    let content: String
    let date: String
    let location: String
    let image: String
    let latitude: Double
    let longitude: Double
    let price: Double?
    let url: String?
    
    enum CodingKeys: String, CodingKey {
        case title
        case content
        case date
        case location
        case image = "post_img"
        case latitude
        case longitude
        case price
        case url
    }
}
