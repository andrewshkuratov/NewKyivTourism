//
//  Client.swift
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

class Client {
    class func Router(endpoint: Endpoint, data: Data?, header: HTTPHeaders?, completion: @escaping (_ response: AFDataResponse<Any>) -> Void) {
        let url =  URL(string: endpoint.description)
        var request = URLRequest(url: url!)
        request.httpMethod = endpoint.method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let data = data {
            request.httpBody = data
        }
        if let header = header {
            request.headers = header
        }
        
        AF.request(request as URLRequestConvertible).responseJSON { response in
            completion(response)
        }
    }
}
