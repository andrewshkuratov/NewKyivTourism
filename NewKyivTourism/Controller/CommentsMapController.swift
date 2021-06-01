//
//  CommentsMapController.swift
//  NewKyivTourism
//
//  Created by Andrew on 01.06.2021.
//

import UIKit

class CommentsMapController: PathController {
    @IBOutlet weak var commentButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupButtons()
    }
    
    func setupButtons() {
        startButton.roundCorner(25)
        commentButton.roundCorner(25)
    }
}

extension CommentsMapController {
    @IBAction func showComments(_ sender: Any) {
//        let storyboard = UIStoryboard(name: Constants.Controllers.commentController, bundle: nil)
//        let nextViewController = storyboard.instantiateInitialViewController() as! CommentController
//        nextViewController.locId = routeId
//        nextViewController.path = Constants.Path.route
//        self.navigationController?.pushViewController(nextViewController, animated: true)
    }
    
    override func willMove(toParent parent: UIViewController?) {
        super.willMove(toParent: parent)
        if started {
            saveAchievements.saveDistance(calculateDistance())
            ratingRouteAlert(self.routeId,
                             Constants.Path.route,
                             title: NSLocalizedString("Please, rate this route", comment: "")) {
                print("Worked")
            }
        }
        regions.forEach { (item) in
            locationManager.stopMonitoring(for: item)
        }
    }
}
