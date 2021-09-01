//
//  RoutesPageCategoryLocationController.swift
//  NewKyivTourism
//
//  Created by Andrew on 03.06.2021.
//

import Foundation
import Alamofire
import AlamofireImage
import FaveButton

class RoutesPageCategoryLocationController: UITableViewController {
    var locations: Array<LocationModel> = []
    var favourites: Array<LocationModel> = []
    var index: Int?
    var likeTable = LikeTable()
        
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        userIsLoggedInCheck { (isLogged) in
            if isLogged {
                self.likeTable.getFavourites { favs in
                    self.favourites = favs
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: Constants.Cells.mainLocationCell, bundle: nil), forCellReuseIdentifier: Constants.Cells.mainLocationCell)
        loadData()
    }
    
    func loadData() {
        createSpinnerView {
            if let index = self.index {
                Network.GetLocationByIndex("\(index)") { (location, message) in
                    guard let location = location else {
                        self.loadAlert(message!) {
                            self.loadData()
                        }
                        return
                    }
                    self.locations = location
                    self.tableView.reloadData()
                }
            }
        }
    }
}

extension RoutesPageCategoryLocationController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locations.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Cells.mainLocationCell) as! MainPageLocationCell
        let item = locations[indexPath.row]
        cell.setup(item: item, favourites: favourites)
        cell.heartButton.addTarget(self, action: #selector(likeAction(_:)), for: .touchUpInside)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Constants.Metrics.width
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = locations[indexPath.row]
        showLocationController(item: item)
    }
    
    @objc
    func likeAction(_ sender: FaveButton) {
        userIsLoggedInCheck { isLogged in
            if isLogged {
                if !self.favourites.contains(where: { (item) -> Bool in
                    return item.id == sender.tag
                }) {
                    let dict = ["place_id" : "\(sender.tag)"]
                    let data = try! JSONEncoder().encode(dict)
                    Network.SendLike(data)
                    self.favourites.append(self.locations.first(where: { (i) -> Bool in
                        return i.id == sender.tag
                    })!)
                } else {
                    let dict = ["place_id" : "\(sender.tag)"]
                    let data = try! JSONEncoder().encode(dict)
                    Network.SendDislike(data)
                    self.favourites.removeAll { (i) -> Bool in
                        return i.id == sender.tag
                    }
                }
            } else {
                self.notLoggedInAlert()
                sender.setSelected(selected: false, animated: false)
            }
        }
    }
}
