//
//  CommentsModel.swift
//  NewKyivTourism
//
//  Created by Andrew on 30.05.2021.
//

import Foundation

struct CommentResponse: Codable {
    let success: Bool
    let data: Array<CommentModel>
    let message: String
    enum CodingKeys: String, CodingKey {
        case success
        case data
        case message
    }
}

struct CommentModel: Codable {
    let id: Int
    let userId: Int
    let placeId: Int?
    let routeId: Int?
    let comment: String
    let createdAt: String
    let user: ProfileModel?
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case placeId = "place_id"
        case routeId = "route_id"
        case comment
        case createdAt = "created_at"
        case user
    }
}
