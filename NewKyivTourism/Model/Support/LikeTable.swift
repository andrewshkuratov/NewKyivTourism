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
    func getFavourites(tableView: UITableView) -> Array<LocationModel> {
        var favourites: Array<LocationModel> = []
        Network.sendRequest(endpoint: .favourites, data: nil, type: LocationResponse.self) { result in
            switch result {
            case .success(let response):
                favourites  = response.data
                tableView.reloadData()
                break
            case .failure(_):
                break
            }
        }
        return favourites
    }
    
    func getFavourites(collectionView: UICollectionView) -> Array<LocationModel> {
        var favourites: Array<LocationModel> = []
        Network.sendRequest(endpoint: .favourites, data: nil, type: LocationResponse.self) { result in
            switch result {
            case .success(let response):
                favourites  = response.data
                collectionView.reloadData()
                break
            case .failure(_):
                break
            }
        }
        return favourites
    }
}
