//
//  LikeTableProtocol.swift
//  NewKyivTourism
//
//  Created by Andrew on 10.06.2021.
//

import Foundation
import FaveButton

protocol LikeTableProtocol {
    var favourites: Array<LocationModel> { get set }
    
    func getFavourites()
    func updateTable(favourites: Array<LocationModel>)
}

extension LikeTableProtocol {
    func getFavourites() {
        Network.sendRequest(endpoint: .favourites, data: nil, type: LocationResponse.self) { result in
            switch result {
            case .success(let response):
                self.updateTable(favourites: response.data)
                break
            case .failure(_):
                break
            }
        }
    }
}
