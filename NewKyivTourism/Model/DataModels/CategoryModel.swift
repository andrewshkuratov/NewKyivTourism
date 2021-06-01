//
//  CategoryModel.swift
//  NewKyivTourism
//
//  Created by Andrew on 30.05.2021.
//

import Foundation

struct CategoryResponse: Codable {
    let success: Bool
    let message: String
    let data: Array<CategoryModel>
    
    enum CodingKeys: String, CodingKey {
        case success
        case message
        case data
    }
}

struct CategoryModel: Codable, Equatable {
    let id: Int
    let slug: String
    let title: String

    enum CodingKeys: String, CodingKey {
        case slug
        case id
        case title
    }
}
