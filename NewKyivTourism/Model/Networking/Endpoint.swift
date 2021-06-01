//
//  Endpoints.swift
//  NewKyivTourism
//
//  Created by Andrew on 30.05.2021.
//

import Foundation

enum Endpoint: CustomStringConvertible {
    case logIn
    case signUp
    case profile
    case location
    case routes
    case poster
    case main
    case saveAchievements
    case saveRoute
    case update
    case category
    case favourites
    case like
    case unlike
    case facebook
    case feedback
    case allData
    
    var description: String {
        
        switch self {
        case .logIn :
            return Constants.Network.baseURL + "/oauth/token"
        case .signUp :
            return Constants.Network.baseURL + "/api/register"
        case .profile :
            return Constants.Network.baseURL + "/api/user"
        case .location:
            return Constants.Network.baseURL + "/api" + "/places"
        case.routes:
            return Constants.Network.baseURL + "/api" + "/routes"
        case .poster:
            return Constants.Network.baseURL + "/api" + "/posters"
        case .main:
            return Constants.Network.baseURL + "/api" + "/mainpage"
        case .saveAchievements:
            return Constants.Network.baseURL + "/api/saveachievements"
        case .saveRoute:
            return Constants.Network.baseURL + "/api/routes/store"
        case .update:
            return Constants.Network.baseURL + "/api/user/update"
        case .category:
            return Constants.Network.baseURL + "/api" + "/categories"
        case .favourites:
            return Constants.Network.baseURL + "/api" + "/profile/places"
        case .like:
            return Constants.Network.baseURL + "/api/profile/places/attach"
        case .unlike:
            return Constants.Network.baseURL + "/api/profile/places/detach"
        case .facebook:
            return Constants.Network.baseURL + "/oauth/token"
        case .feedback:
            return Constants.Network.baseURL + "/api/send-email"
        case .allData:
            return Constants.Network.baseURL + "/api/search"
        }
    }
    
    var method: String {
        switch self {
        case .signUp, .logIn, .saveAchievements, .saveRoute, .update, .like, .unlike, .facebook, .feedback, .allData :
            return "POST"
        case .profile, .location, .routes, .poster, .main, .category, .favourites :
            return "GET"
        }
    }
}
