//
//  Network.swift
//  NewKyivTourism
//
//  Created by Andrew on 30.05.2021.
//

import Foundation
import Alamofire
import SwiftyJSON
import AlamofireImage
import FBSDKLoginKit
import FBSDKCoreKit

class Network {
    private static let error = NSLocalizedString("Check your internet connection, or try again later.", comment: "")
    
    typealias result<T> = (Result<T, Error>) -> Void
    
    class func sendRequest<T: Decodable>(endpoint: Endpoint, data: Data?, type: T.Type, completion: @escaping result<T>) {
        let errorMessage = NSLocalizedString("Some error occured", comment: "")
        var header: HTTPHeaders?
        switch endpoint {
        case .favourites, .profile:
            header = getHeader()
            break
        default:
            break
        }
        
        Client.Router(endpoint: endpoint, data: data, header: header) { (response) in
            guard let responseData = response.data else {
                completion(.failure(errorMessage as! Error))
                return
            }
            
            do {
                let decodedData: T = try JSONDecoder().decode(T.self, from: responseData)
                completion(.success(decodedData))
            } catch {
                completion(.failure(error))
            }
        }
    }

    
    //MARK: Authorization Area
    class func FacebookAuth(completion: @escaping(_ message: String?) -> Void) {
        guard let token = AccessToken.current?.tokenString else { return }
        let body = SocialNetworkModel(provider: "facebook", access_token: token)
        let data = try! JSONEncoder().encode(body)
        Client.Router(endpoint: .facebook, data: data, header: nil) { (response) in
            if let data = response.data {
                saveTokens(data) ? completion(nil) : completion(error)
            } else {
                completion(error)
            }
        }
    }
    
    class func GoogleAuth(_ token: String, completion: @escaping(_ message: String?) -> Void) {
        let body = SocialNetworkModel(provider: "google", access_token: token)
        let data = try! JSONEncoder().encode(body)
        Client.Router(endpoint: .facebook, data: data, header: nil) { (response) in
            if let data = response.data {
                saveTokens(data) ? completion(nil) : completion(error)
            } else {
                completion(error)
            }
        }
    }
    
    class func Authorize(data: Data, completion: @escaping(_ message: String?) -> Void) {
        Client.Router(endpoint: .logIn, data: data, header: nil) { response in
            if let data = response.data {
                if saveTokens(data) {
                    UserDefaults.standard.setValue(true, forKey: Constants.UserDefaults.isLoggedIn)
                    completion(nil)
                } else {
                    completion(error)
                }
            } else {
                completion(error)
            }
            
        }
    }
    
    //MARK: Like/Unlike location
    class func SendLike(_ index: Data) {
        Client.Router(endpoint: .like, data: index, header: getHeader()) { (response) in
            print(response.debugDescription)
        }
    }
    
    class func SendDislike(_ index: Data) {
        Client.Router(endpoint: .unlike, data: index, header: getHeader()) { (response) in
            print(response.debugDescription)
        }
    }
    
    //MARK: Create Route/Location rating
    class func PostRating(_ type: String, _ locId: Int, _ rating: Int, completion: @escaping() -> Void) {
        let url = URL(string: Constants.Network.baseURL + "/api/\(type)/\(locId)/rate")
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.headers = getHeader()
        let commData = ["rate" : "\(rating)"]
        let d = try! JSONEncoder().encode(commData)
        request.httpBody = d
        
        AF.request(request as URLRequestConvertible).responseJSON { response in
            print(response.debugDescription)
            completion()
        }
    }
    
    //MARK: Location
    class func GetLocationByIndex(_ index: String, completion: @escaping(_ main: Array<LocationModel>?, _ error: String?) -> Void) {
        let url = URL(string: Endpoint.category.description + "/\(index)")
        var request = URLRequest(url: url!)
        request.method = .get
        
        AF.request(request as URLRequestConvertible).responseJSON { (response) in
            print(response.debugDescription)
            if let data = response.data {
                do {
                    let userInfo = try JSONDecoder().decode(LocationResponse.self, from: data)
                    completion(userInfo.data, nil)
                } catch {
                    completion(nil, error.localizedDescription)
                }
            } else {
                completion(nil, error)
            }
        }
    }
    
    //MARK: Get/Create comments
    class func GetComments(_ type: String, _ locId: Int, completion: @escaping(Result<Array<CommentModel>, Error>) -> Void) {
        let url = URL(string: Constants.Network.baseURL + "/api/\(type)/\(locId)/comments")
        var request = URLRequest(url: url!)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        AF.request(request as URLRequestConvertible).responseJSON { response in
            print(response.debugDescription)
            if let data = response.data {
                do {
                    let userInfo = try JSONDecoder().decode(CommentResponse.self, from: data)
                    completion(.success(userInfo.data))
                } catch {
                    completion(.failure(error))
                }
            } else {
                completion(.failure(error as! Error))
            }
        }
    }
    
    class func PostComment(_ type: String, _ locId: Int, _ comment: String, completion: @escaping() -> Void) {
        let url = URL(string: Constants.Network.baseURL + "/api/\(type)/\(locId)/comments/store")
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.headers = getHeader()
        let commData = ["comment" : comment]
        let d = try! JSONEncoder().encode(commData)
        request.httpBody = d
        AF.request(request as URLRequestConvertible).responseJSON { response in
            print(response.debugDescription)
            completion()
        }
    }
}

//MARK: Service Functions
extension Network {
    private class func saveTokens(_ data: Data) -> Bool {
        guard let access_token = JSON(data)["access_token"].string else {
            return false
        }
        guard let token_type = JSON(data)["token_type"].string else {
            return false
        }
        UserDefaults.standard.setValue(token_type, forKey: Constants.UserDefaults.tokenType)
        UserDefaults.standard.setValue(access_token, forKey: Constants.UserDefaults.accessToken)
        return true
    }
    
    private class func getHeader() -> HTTPHeaders {
        let defaults = UserDefaults.standard
        let type = defaults.string(forKey: Constants.UserDefaults.tokenType)!
        let token = defaults.string(forKey: Constants.UserDefaults.accessToken)!
        let header: HTTPHeaders = ["Authorization" : type + " " + token]
        return header
    }
}
