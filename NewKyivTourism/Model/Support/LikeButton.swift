//
//  LikeButton.swift
//  NewKyivTourism
//
//  Created by Andrew on 02.06.2021.
//

import Foundation
import FaveButton

class LikeButton: FaveButton {
    func setLiked(favourites: Array<LocationModel>) {
        let locationId = self.tag
        self.setSelected(selected: favourites.contains(where: { (i) -> Bool in
                                        return locationId == i.id
                                    }), animated: false)
    }
}
