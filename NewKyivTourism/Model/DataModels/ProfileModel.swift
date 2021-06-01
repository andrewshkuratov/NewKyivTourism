//
//  ProfileModel.swift
//  NewKyivTourism
//
//  Created by Andrew on 30.05.2021.
//

import Foundation

struct ProfileResponse: Codable {
    let success: Bool
    let message: String
    let data: ProfileModel
    enum CodingKeys: String, CodingKey {
        case success
        case message
        case data
    }
}

struct ProfileModel: Codable {
    var name: String?
    var surname: String?
    var email: String?
    var login: String?
    var country: String?
    var sex: String?
    var date: String?
    var password: String?
    var distance: Double?
    var avatar: String?
    var about: String?
    var id: Int?
    
    init(name: String,
         surname: String,
         email: String,
         login: String,
         country: String,
         sex: String,
         date: String,
         password: String) {
        self.name = name
        self.surname = surname
        self.email = email
        self.login = login
        self.country = country
        self.sex = sex
        self.date = date
        self.password = password
    }
    
    init(name: String,
         surname: String,
         login: String,
         country: String,
         date: String,
         about: String) {
        self.name = name
        self.surname = surname
        self.login = login
        self.country = country
        self.date = date
        self.about = about
    }
    
    enum CodingKeys: String, CodingKey {
        case name
        case surname
        case email
        case login
        case country
        case sex
        case date
        case password
        case distance
        case avatar
        case about
        case id
    }
}
