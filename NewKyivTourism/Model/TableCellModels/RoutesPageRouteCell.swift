//
//  RoutesPageRouteCell.swift
//  NewKyivTourism
//
//  Created by Andrew on 03.06.2021.
//

import Foundation

class RoutesPageRouteCell: UITableViewCell {
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var rateNumber: UILabel!
    @IBOutlet weak var commentsCount: UILabel!
    @IBOutlet weak var routeLength: UILabel!
    
    func setup(_ item: RouteModel) {
        name.text = item.title
        if let rate = item.ratingsAvg {
            let r = Double(rate) ?? 0
            rateNumber.text = String(format: "%.1f", r)
        } else {
            rateNumber.text = "0"
        }
        commentsCount.text = String(describing: item.routeCommentsCount ?? 0)
        routeLength.text = String(format: "%.2f", item.length ?? 0) + " " + NSLocalizedString("km", comment: "")
    }
}
