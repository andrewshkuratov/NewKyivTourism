//
//  LikeTable.swift
//  NewKyivTourism
//
//  Created by Andrew on 31.05.2021.
//

import Foundation
import FaveButton
import FBSDKLoginKit
import FBSDKCoreKit
import GoogleSignIn

class LikeTable {
    public func getFavourites(completion: @escaping(_ favourites: Array<LocationModel>) -> Void) {
        var favourites: Array<LocationModel> = []
        Network.sendRequest(endpoint: .favourites, data: nil, type: LocationResponse.self) { result in
            switch result {
            case .success(let response):
                favourites  = response.data
                completion(favourites)
                break
            case .failure(_):
                break
            }
        }
    }
}
