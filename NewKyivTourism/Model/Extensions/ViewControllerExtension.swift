//
//  ViewControllerExtension.swift
//  NewKyivTourism
//
//  Created by Andrew on 31.05.2021.
//

import Foundation
import FBSDKLoginKit
import FBSDKCoreKit
import GoogleSignIn

extension UIViewController {
    func setMenu(_ menuBarButton: UIBarButtonItem) {
        if self.revealViewController() != nil {
            menuBarButton.target = self.revealViewController()
            menuBarButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
    }
    
    func createSpinnerView(completion: @escaping() -> Void) {
        let child = SpinnerViewController()
        child.spinner.tintColor = .label

        // add the spinner view controller
        self.addChild(child)
        child.view.frame = view.frame
        self.view.addSubview(child.view)
        child.didMove(toParent: self)

        DispatchQueue.main.async {
            completion()
            child.willMove(toParent: nil)
            child.view.removeFromSuperview()
            child.removeFromParent()
        }
    }
    
    func loadAlert(_ message: String, completion: @escaping() -> Void) {
        let alert = UIAlertController(title: NSLocalizedString("Error", comment: ""), message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Try again", comment: ""), style: .default, handler: { (alert) in
            completion()
        }))
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
    
    func registrationAlert(_ message: String) {
        let alert = UIAlertController(title: NSLocalizedString("Error", comment: ""), message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Ok", comment: ""), style: .default, handler: nil))
        self.present(alert, animated: true)
    }
    
//    func notLoggedInAlert() {
//        let dialogMessage = UIAlertController(title: NSLocalizedString("Error", comment: ""),
//                                              message: NSLocalizedString("You are not entered yout account", comment: ""),
//                                              preferredStyle: .alert)
//        let register = UIAlertAction(title: NSLocalizedString("Enter", comment: ""), style: .default) { (action) in
//            let storyboard = UIStoryboard(name: "Registration", bundle: .none)
//            let nextVC = storyboard.instantiateViewController(identifier: "registrationForm") as! RegistrationForm
//            self.navigationController?.pushViewController(nextVC, animated: true)
//        }
//        let ok = UIAlertAction(title: NSLocalizedString("Ok", comment: ""), style: .default, handler: nil)
//        dialogMessage.addAction(register)
//        dialogMessage.addAction(ok)
//        self.present(dialogMessage, animated: true, completion: nil)
//    }
    
    func ratingAlert(_ id: Int, _ path: String, title: String) {
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .actionSheet)
        let oneStar = UIAlertAction(title: NSLocalizedString("Awful", comment: ""), style: .default) { (action) in
            Network.PostRating(path, id, 1) {

            }
        }
        let twoStar = UIAlertAction(title: NSLocalizedString("Don't like", comment: ""), style: .default) { (action) in
            Network.PostRating(path, id, 2) {

            }
        }
        let threeStar = UIAlertAction(title: NSLocalizedString("Normal", comment: ""), style: .default) { (action) in
            Network.PostRating(path, id, 3) {

            }
        }
        let fourStar = UIAlertAction(title: NSLocalizedString("Like", comment: ""), style: .default) { (action) in
            Network.PostRating(path, id, 4) {

            }
        }
        let fiveStar = UIAlertAction(title: NSLocalizedString("Very like", comment: ""), style: .default) { (action) in
            
            Network.PostRating(path, id, 5) {

            }
        }

        let cancel = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: .none)
        alert.addAction(oneStar)
        alert.addAction(twoStar)
        alert.addAction(threeStar)
        alert.addAction(fourStar)
        alert.addAction(fiveStar)
        alert.addAction(cancel)

        self.present(alert, animated: true, completion: nil)
    }
    
    func ratingRouteAlert(_ id: Int, _ path: String, title: String, completion: @escaping() -> Void) {
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .actionSheet)
        let oneStar = UIAlertAction(title: NSLocalizedString("Awful", comment: ""), style: .default) { (action) in
            Network.PostRating(path, id, 1) {

            }
            completion()
        }
        let twoStar = UIAlertAction(title: NSLocalizedString("Don't like", comment: ""), style: .default) { (action) in
            Network.PostRating(path, id, 2) {

            }
            completion()
        }
        let threeStar = UIAlertAction(title: NSLocalizedString("Normal", comment: ""), style: .default) { (action) in
            Network.PostRating(path, id, 3) {

            }
            completion()
        }
        let fourStar = UIAlertAction(title: NSLocalizedString("Like", comment: ""), style: .default) { (action) in
            Network.PostRating(path, id, 4) {

            }
            completion()
        }
        let fiveStar = UIAlertAction(title: NSLocalizedString("Very like", comment: ""), style: .default) { (action) in
            Network.PostRating(path, id, 5) {

            }
            completion()
        }

        let cancel = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel) { action in
            completion()
        }

        alert.addAction(oneStar)
        alert.addAction(twoStar)
        alert.addAction(threeStar)
        alert.addAction(fourStar)
        alert.addAction(fiveStar)
        alert.addAction(cancel)

        self.present(alert, animated: true, completion: nil)
    }
    
    func userIsLoggedInCheck(completion: @escaping(_ isLogged: Bool) -> Void) {
        if UserDefaults.standard.bool(forKey: Constants.UserDefaults.isLoggedIn) {
            completion(true)
        }
        else if ((AccessToken.current?.isExpired) != nil) {
            completion(true)
        }
        else if let signIn = GIDSignIn.sharedInstance(), signIn.hasPreviousSignIn() {
            completion(true)
        }
        else {
            completion(false)
        }
    }
    
    func invokeAlert(message: String) {
        let alert = UIAlertController(title: NSLocalizedString("Error", comment: ""), message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Ok", comment: ""), style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func showCommentsController(routeId: Int, endpoint: String) {
        let storyboard = UIStoryboard(name: Constants.Controllers.commentController, bundle: nil)
        let nextViewController = storyboard.instantiateInitialViewController() as! CommentController
        nextViewController.locId = routeId
        nextViewController.path = endpoint
        self.navigationController?.pushViewController(nextViewController, animated: true)
    }
    
    func showLocationMapController(locations: Array<LocationModel>) {
        let storyboard = UIStoryboard(name: Constants.Controllers.noCommentsMapController, bundle: nil)
        let nextViewController = storyboard.instantiateInitialViewController() as! NoCommentsMapController
        nextViewController.locations = locations
        nextViewController.routeId = -1
        self.navigationController?.pushViewController(nextViewController, animated: true)
    }
    
    func showPosterController(item: PosterModel) {
        let storyboard = UIStoryboard(name: Constants.Controllers.posterDetailController, bundle: nil)
        let nextViewController = storyboard.instantiateViewController(identifier: Constants.Controllers.posterDetailController) as! PosterDetailController
        nextViewController.posterData = item
        self.navigationController?.pushViewController(nextViewController, animated: true)
    }
    
    func showLocationController(item: LocationModel) {
        let storyboard = UIStoryboard(name: Constants.Controllers.locationDetailController, bundle: nil)
        let nextViewController = storyboard.instantiateViewController(withIdentifier: Constants.Controllers.locationDetailController) as! LocationDetailController
        nextViewController.locationInfo = item
        self.navigationController?.pushViewController(nextViewController, animated: true)
    }
    
    func showRouteController(item: RouteModel) {
        let storyboard = UIStoryboard(name: Constants.Controllers.commentsMapController, bundle: nil)
        let nextViewController = storyboard.instantiateViewController(withIdentifier: Constants.Controllers.commentsMapController) as! CommentsMapController
        nextViewController.locations = item.places
        nextViewController.routeId = item.id
        self.navigationController?.pushViewController(nextViewController, animated: true)
    }
    
    func showRoutesPageCategoryLocation(item: CategoryModel) {
        let storyboard = UIStoryboard(name: "RoutesPageView", bundle: nil)
        let nextViewController = storyboard.instantiateViewController(withIdentifier: "CategoryLocationController") as! RoutesPageCategoryLocationController
        nextViewController.index = item.id
        navigationController?.pushViewController(nextViewController, animated: true)
    }
}
