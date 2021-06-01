//
//  TableViewExtensions.swift
//  NewKyivTourism
//
//  Created by Andrew on 31.05.2021.
//

import Foundation

extension UITableViewController {
    func emptyMessage(message: String) {
        let rect = CGRect(origin: CGPoint(x: 0,y :0), size: CGSize(width: self.view.bounds.size.width, height: self.view.bounds.size.height))
        let emptyMessageLabel: UILabel = {
            let eml = UILabel(frame: rect)
            eml.text = message
            eml.textColor = .label
            eml.numberOfLines = 0
            eml.textAlignment = .center
            eml.sizeToFit()
            return eml
        }()

        self.tableView.backgroundView = emptyMessageLabel;
        self.tableView.separatorStyle = .none;
    }
}
