//
//  LoginModel.swift
//  NewKyivTourism
//
//  Created by Andrew on 30.05.2021.
//

import Foundation

struct LoginModel: Codable {
    var client_secret = "p43ZmVSHg7oM2LQgfWaKMVmKfTwwsovhwPSMVVCA"
    var grant_type = "password"
    var client_id = 2
    var username: String
    var password: String
    
    init(username: String, password: String) {
        self.username = username
        self.password = password
    }
}
