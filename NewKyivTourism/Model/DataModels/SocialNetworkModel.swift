//
//  SocialNetworkModel.swift
//  NewKyivTourism
//
//  Created by Andrew on 30.05.2021.
//

import Foundation

struct SocialNetworkModel: Encodable {
    let client_id = 2
    let client_secret = "p43ZmVSHg7oM2LQgfWaKMVmKfTwwsovhwPSMVVCA"
    let grant_type = "social"
    let provider: String
    let access_token: String
    
    internal init(provider: String, access_token: String) {
        self.provider = provider
        self.access_token = access_token
    }
}
