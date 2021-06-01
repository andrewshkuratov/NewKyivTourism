//
//  Constants.swift
//  NewKyivTourism
//
//  Created by Andrew on 30.05.2021.
//

import Foundation
import UIKit
import CoreLocation

struct Constants {
    struct Locations {
        static let kyivCenter = CLLocation(latitude: 50.45105, longitude: 30.52251)
    }
    
    struct Color {
        static let bgMainColor: UIColor = UIColor.init(cgColor: CGColor(red: 248/255, green: 240/255, blue: 216/255, alpha: 1))
        static let badgeButtonColor: UIColor = UIColor.init(cgColor: CGColor(red: 35/255, green: 116/255, blue: 231/255, alpha: 1))
        static let contentsTypeColor: UIColor = UIColor.init(cgColor: CGColor(red: 98/255, green: 138/255, blue: 91/255, alpha: 1))
        static let routeNameColor: UIColor = UIColor.init(cgColor: CGColor(red: 178/255, green: 88/255, blue: 95/255, alpha: 1))
    }
    
    struct Metrics {
        static let width = UIScreen.main.bounds.width
        static let height = UIScreen.main.bounds.height
        static let squareMetric = CGRect(x: 0, y: 0, width: width, height: width)
        static let categoryLabelCornerRadius: CGFloat = 5
        static let cornerRadius: CGFloat = 8
    }
    
    struct UserDefaults {
        static let isLoggedIn = "userLoggedIn"
        static let tokenType = "tokenType"
        static let accessToken = "accessToken"
    }
    
    struct Images {
        static let imageSet1 = ["kyiv.png", "kyiv1.jpg", "kyiv2.jpg"]
        static let imageSet2 = ["kyiv3.jpg", "kyiv4.jpg", "kyiv5.jpg"]
        static let imageSet3 = ["kyiv6.jpg", "kyiv7.jpg", "kyiv8.jpg"]
        static let userImage = UIImage(named: "userImage")
        
        static let redMapImage = UIImage(named: "redMapPin")
        static let blueMapImage = UIImage(named: "blueMapPin")
        static let greenMapImage = UIImage(named: "greenMapPin")
        static let orangeMapImage = UIImage(named: "orangeMapPin")
        static let violetMapImage = UIImage(named: "violetMapPin")
        static let yellowMapImage = UIImage(named: "yellowMapPin")
        static let pinsSet = [redMapImage, greenMapImage, orangeMapImage, blueMapImage, yellowMapImage, violetMapImage]
    }
    
    struct CategoriesColours {
        static let orange = UIColor(red: 255/255, green: 119/255, blue: 0, alpha: 1)
        static let red = UIColor(red: 255/255, green: 0, blue: 0, alpha: 1)
        static let blue = UIColor(red: 0, green: 113/255, blue: 255/255, alpha: 1)
        static let green = UIColor(red: 0, green: 134/255, blue: 0, alpha: 1)
        static let violet = UIColor(red: 255/255, green: 0, blue: 121/255, alpha: 1)
        static let yellow = UIColor(red: 251/255, green: 255/255, blue: 0, alpha: 1)
        static let colorSet = [red, green, orange, blue, violet]
    }
    
    struct Network {
        static let baseURL = "http://devtourist.devovrutsky.pp.ua"
    }
    
    struct Controllers {
        static let posterDetailController = "PosterDetailController"
        static let locationDetailController = "LocationDetailController"
        static let commentsMapController = "CommentsMapView"
        static let noCommentsMapController = "NoCommentsMapController"
        static let commentController = "CommentController"
        static let notLoggedInController = "Registration"
    }
    
    struct Cells {
        static let mainLocationCell = "MainPageLocationCell"
        static let mainPosterCell = "MainPagePosterCell"
        static let mainRouteCell = "MainPageRouteCell"
        
        static let categoryCell = "CategoryCell"
        static let commentCell = "CommentCell"
        static let buildPathCell = "UserBuildPathCell"
    }
    
    struct Path {
        static let location = "places"
        static let route = "routes"
    }
}
