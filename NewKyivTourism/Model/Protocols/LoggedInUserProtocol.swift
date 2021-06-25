//
//  LoggedInUserProtocol.swift
//  NewKyivTourism
//
//  Created by Andrew on 10.06.2021.
//

import Foundation
import FBSDKLoginKit
import GoogleSignIn

protocol LoggedInUserProtocol {
    func userIsLoggedIn(completion: @escaping(_ isLogged: Bool) -> Void)
}

extension LoggedInUserProtocol {
    func userIsLoggedInCheck(completion: @escaping(_ isLogged: Bool) -> Void) {
        if UserDefaults.standard.bool(forKey: Constants.UserDefaults.isLoggedIn) {
            completion(true)
        } else if ((AccessToken.current?.isExpired) != nil) {
            completion(true)
        } else if let signIn = GIDSignIn.sharedInstance(), signIn.hasPreviousSignIn() {
            completion(true)
        } else {
            completion(false)
        }
    }
}
