//
//  RoutesPageController.swift
//  NewKyivTourism
//
//  Created by Andrew on 03.06.2021.
//

import Foundation
import UIKit

class RoutesPageController: UITabBarController {
    @IBOutlet weak var menuBarButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setMenu(menuBarButton)
    }
}
