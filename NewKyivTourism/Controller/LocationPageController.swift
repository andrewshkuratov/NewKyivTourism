//
//  LocationPageController.swift
//  NewKyivTourism
//
//  Created by Andrew on 07.06.2021.
//

import Foundation
import RSSelectionMenu
import CoreLocation
import FaveButton

class LocationPageController: UITableViewController {
    @IBOutlet weak var menuBarButton: UIBarButtonItem!
    
    var sortingOptions = [NSLocalizedString("By rating", comment: ""),
                          NSLocalizedString("By rating(decrease)", comment: "")]
    var selectedOption = [NSLocalizedString("By rating", comment: "")]
    
    let locationManager = CLLocationManager()
    var currentLocation: CLLocationCoordinate2D?
    
    var likeTable = LikeTable()
    var locations: Array<LocationModel> = []
    var favourites: Array<LocationModel> = []
    
    override func viewDidLoad() {
        setMenu(menuBarButton)
        setupLocation()
        tableView.register(UINib(nibName: Constants.Cells.mainLocationCell, bundle: nil),
                           forCellReuseIdentifier: Constants.Cells.mainLocationCell)
        loadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.userIsLoggedInCheck { (isLogged) in
            if isLogged {
                self.likeTable.getFavourites { favs in
                    self.favourites = favs
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    func loadData() {
        Network.sendRequest(endpoint: .location, data: nil, type: LocationResponse.self) { result in
            switch result {
            case .success(let response):
                self.locations = response.data
                self.sortByRating()
                self.tableView.reloadData()
                break
            case .failure(let error):
                self.loadAlert(error.localizedDescription) {
                    
                }
                break
            }
        }
    }
    
    @IBAction func sortLocations(_ sender: Any) {
        let selectionMenu = RSSelectionMenu(selectionStyle: .single, dataSource: sortingOptions) { (cell, cat, indexPath) in
            cell.textLabel?.text = cat
        }
        
        selectionMenu.setSelectedItems(items: selectedOption) { [weak self] (item, index, isSelected, selectedItems) in
            self?.selectedOption = selectedItems
        }
        
        selectionMenu.show(style: .present, from: self)
                                
        selectionMenu.onDismiss = { [weak self] selectedItems in
            guard let item = selectedItems.first else {
                return
            }
            self!.selectedOption[0] = item
            if item == self!.sortingOptions[0] {
                self!.sortByRating()
            } else if item == self!.sortingOptions[1] {
                self!.sortByRatingDecrease()
            } else if item == self!.sortingOptions[2] {
                self!.sortByNearest()
            } else if item == self!.sortingOptions[3] {
                self!.sortByFarest()
            }
        }
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

extension LocationPageController {
    func sortByRating() {
        locations = locations.sorted() { Double($0.ratingAvg ?? "0")! > Double($1.ratingAvg ?? "0")! }
        tableView.reloadData()
    }
    
    func sortByRatingDecrease() {
        locations = locations.sorted() { Double($0.ratingAvg ?? "0")! < Double($1.ratingAvg ?? "0")! }
        tableView.reloadData()
    }
    
    func sortByNearest() {
        guard let loc = currentLocation else {
            return
        }
        locations = locations.sorted() {
            CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude).distance(from: loc) < CLLocationCoordinate2D(latitude: $0.latitude, longitude: $1.longitude).distance(from: loc)
        }
        tableView.reloadData()
    }
    
    func sortByFarest() {
        guard let loc = currentLocation else {
            return
        }
        locations = locations.sorted() {
            CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude).distance(from: loc) > CLLocationCoordinate2D(latitude: $0.latitude, longitude: $1.longitude).distance(from: loc)
        }
        tableView.reloadData()
    }
}

extension LocationPageController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locations.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Constants.Metrics.width
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Cells.mainLocationCell) as! MainPageLocationCell
        let item = locations[indexPath.row]
        cell.setup(item: item, favourites: favourites)
        cell.heartButton.addTarget(self, action: #selector(likeAction(_:)), for: .touchUpInside)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = locations[indexPath.row]
        let storyboard = UIStoryboard(name: Constants.Controllers.locationDetailController, bundle: nil)
        let nextViewController = storyboard.instantiateViewController(withIdentifier: Constants.Controllers.locationDetailController) as! LocationDetailController
        nextViewController.locationInfo = item
        navigationController?.pushViewController(nextViewController, animated: true)
    }
}

extension LocationPageController: CLLocationManagerDelegate {
    func setupLocation() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        if locationManager.authorizationStatus == .authorizedAlways || locationManager.authorizationStatus == .authorizedWhenInUse {
            sortingOptions.append(NSLocalizedString("By nearest location", comment: ""))
            sortingOptions.append(NSLocalizedString("By farest location", comment: ""))
        }
    }
        
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = manager.location?.coordinate else { return }
        currentLocation = location
    }
}
