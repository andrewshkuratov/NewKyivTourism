//
//  ViewExtensions.swift
//  NewKyivTourism
//
//  Created by Andrew on 31.05.2021.
//

import Foundation
import UIKit

extension UIView {
    func roundView() {
        self.layer.masksToBounds = false
        self.layer.cornerRadius = self.bounds.height / 2
        self.clipsToBounds = true
    }
    
    func makeDarker() {
        backgroundColor = UIColor.black.withAlphaComponent(0.5)
    }
    
    func addConstraintsWithFormat(format: String, views: UIView...) {
        var viewsDictionary = [String: UIView]()
        for (index, view) in views.enumerated() {
            let key = "v\(index)"
            viewsDictionary[key] = view
        }
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: format, options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: viewsDictionary))
    }
    
    func addConstrained(subview: UIView) {
        addSubview(subview)
        subview.translatesAutoresizingMaskIntoConstraints = false
        subview.topAnchor.constraint(equalTo: topAnchor).isActive = true
        subview.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        subview.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        subview.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }
    
    func addBorder(_ color: UIColor, _ width: CGFloat = Constants.Metrics.cornerRadius) {
        self.layer.borderWidth = width
        self.layer.borderColor = color.cgColor
    }
    
    func roundCorner(_ radius: CGFloat = Constants.Metrics.cornerRadius) {
        self.layer.masksToBounds = true
        self.layer.cornerRadius = radius
    }
}
