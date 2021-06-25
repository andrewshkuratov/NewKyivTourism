//
//  SettingsPageController.swift
//  NewKyivTourism
//
//  Created by Andrew on 25.06.2021.
//

import Foundation

class SettingsPageController: UIViewController {
    @IBOutlet weak var menuBarButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setMenu(menuBarButton)
    }
    
    @IBAction func openAppSettings(_ sender: Any) {
        let url = URL(string:UIApplication.openSettingsURLString)
        if UIApplication.shared.canOpenURL(url!){
            UIApplication.shared.open(url!, options: [:], completionHandler: nil)
        }
    }
}
