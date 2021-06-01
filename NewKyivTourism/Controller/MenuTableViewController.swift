//
//  MenuTableViewController.swift
//  NewKyivTourism
//
//  Created by Andrew on 31.05.2021.
//

import UIKit
import FBSDKLoginKit
import FBSDKCoreKit

class MenuTableViewController: UITableViewController, SWRevealViewControllerDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 8 {
            userIsLoggedInCheck { isLogged in
                if isLogged {
                    self.performSegue(withIdentifier: "userLoggedIn", sender: self)
                } else {
                    self.performSegue(withIdentifier: "userNotLoggedIn", sender: self)
                }
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
}
