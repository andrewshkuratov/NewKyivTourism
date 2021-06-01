//
//  AchievementsServer.swift
//  NewKyivTourism
//
//  Created by Andrew on 30.05.2021.
//

import Foundation
import Alamofire
import SwiftyJSON

class AchievementsServer {
    //MARK: Save User achievements
    private func saveAchievements(data: Data) {
        let header = getHeader()
        Client.Router(endpoint: .saveAchievements, data: data, header: header) { (response) in
            
        }
    }
    
    //MARK: Save route created by user
    private func saveRoute(data: Data, _ completion: @escaping(_ route: Int) -> Void) {
        let header = getHeader()
        Client.Router(endpoint: .saveRoute, data: data, header: header) { (response) in
            switch response.result {
            case .success:
                if JSON(response.data!)["success"].int == 1 {
                    completion(JSON(response.data!)["data"]["route_id"].int!)
                }
                break
            case .failure:
                fatalError("")
            }
        }
    }
    
    func createRoute(_ locations: Array<LocationModel>) -> Int {
        var array: Array<String> = []
        locations.forEach { (loc) in
            array.append(loc.title)
        }
        let dictionary = ["way_points" : array]
        let data = try! JSONSerialization.data(withJSONObject: dictionary, options: [])
        var routeId: Int = 0
        saveRoute(data: data) { routeIdentifier in
            routeId = routeIdentifier
        }
        return routeId
    }
    
    func saveDistance(_ distance: Double) {
        let dictionary = ["distance" : "\(distance)"]
        let data = try! JSONSerialization.data(withJSONObject: dictionary, options: [])
        saveAchievements(data: data)
    }
    
    func savePlace(_ region: Int) {
        let dictionary = ["place_id" : region]
        let data = try! JSONSerialization.data(withJSONObject: dictionary, options: [])
        saveAchievements(data: data)
    }
    
    func saveRoute(_ routeId: Int) {
        let dictionary1 = ["route_id" : "\(routeId)"]
        let data1 = try! JSONSerialization.data(withJSONObject: dictionary1, options: [])
        saveAchievements(data: data1)
    }
    
    private func getHeader() -> HTTPHeaders {
        let defaults = UserDefaults.standard
        let type = defaults.string(forKey: Constants.UserDefaults.tokenType)!
        let token = defaults.string(forKey: Constants.UserDefaults.accessToken)!
        let header: HTTPHeaders = ["Authorization" : type + " " + token]
        return header
    }
}
