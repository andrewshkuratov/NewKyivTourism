//
//  LocationModel.swift
//  NewKyivTourism
//
//  Created by Andrew on 30.05.2021.
//

import Foundation

struct LocationResponse: Codable {
    let success: Bool
    let message: String
    let data: Array<LocationModel>
    enum CodingKeys: String, CodingKey {
        case success
        case message
        case data
    }
}

struct LocationModel: Codable {
    let id: Int
    let catId: Int?
    let title: String
    let content: String?
    let location: String?
    let latitude: Double
    let longitude: Double
    let image: String?
    let ratingAvg: String?
    let category: CategoryModel?
    let commentsCount: Int?
    
    enum CodingKeys: String, CodingKey {
        case id
        case catId = "cat_id"
        case title
        case content
        case location
        case latitude
        case longitude
        case image = "post_img"
        case category
        case ratingAvg = "ratings_avg"
        case commentsCount = "comments_count"
    }
}
