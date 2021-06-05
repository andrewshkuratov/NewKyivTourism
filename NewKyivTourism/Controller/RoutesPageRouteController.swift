//
//  RoutesPageRouteController.swift
//  NewKyivTourism
//
//  Created by Andrew on 03.06.2021.
//

import Foundation
import RSSelectionMenu
import CoreLocation

class RoutesPageRouteController: UITableViewController {
    var routes: Array<RouteModel> = []
    
    let sortingOptions = [NSLocalizedString("By name", comment: ""),
                          NSLocalizedString("By name(decrease)", comment: ""),
                          NSLocalizedString("The nearest start of the route", comment: ""),
                          NSLocalizedString("The farthest start of the route", comment: ""),
                          NSLocalizedString("Most locations", comment: ""),
                          NSLocalizedString("Least locations", comment: ""),
                          NSLocalizedString("By rating", comment: ""),
                          NSLocalizedString("By rating(decrease)", comment: ""),
                          NSLocalizedString("By length", comment: ""),
                          NSLocalizedString("By length(decrease)", comment: "")]
    var selectedOption = [NSLocalizedString("By name", comment: "")]
    
    let locationManager = CLLocationManager()
    var currentLocation: CLLocationCoordinate2D?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLocation()
        tableView.register(UINib(nibName: Constants.Cells.routeRoutesCell, bundle: nil), forCellReuseIdentifier: Constants.Cells.routeRoutesCell)
        loadData()
    }
}

extension RoutesPageRouteController {
    func loadData() {
        createSpinnerView {
            Network.sendRequest(endpoint: .routes, data: nil, type: RouteResponse.self) { result in
                switch result {
                case .success(let response):
                    self.routes = response.data
                    self.sortByName()
                    self.tableView.reloadData()
                    break
                case .failure(let error):
                    self.loadAlert(error.localizedDescription) {
                        
                    }
                    break
                }
            }
        }
    }
    
    @IBAction func sortRoutes(_ sender: Any) {
        let selectionMenu = RSSelectionMenu(selectionStyle: .single, dataSource: sortingOptions) { (cell, cat, indexPath) in
            cell.textLabel?.text = cat
        }
        
        selectionMenu.setSelectedItems(items: selectedOption) { [weak self] (item, index, isSelected, selectedItems) in
            self?.selectedOption = selectedItems
        }
        
        selectionMenu.show(style: .present, from: self)
                
        selectionMenu.onDismiss = { [weak self] selectedItems in
            let item = selectedItems.first!
            self!.selectedOption[0] = item
            if item == self!.sortingOptions[0] {
                self!.sortByName()
            } else if item == self!.sortingOptions[1] {
                self!.sortByNameReverse()
            } else if item == self!.sortingOptions[2] {
                self!.sortByNearest()
            } else if item == self!.sortingOptions[3] {
                self!.sortByFarest()
            } else if item == self!.sortingOptions[4] {
                self!.sortByNumberOfLocations()
            } else if item == self!.sortingOptions[5] {
                self!.sortByNumberOfLocationsReverse()
            } else if item == self!.sortingOptions[6] {
                self!.sortByRating()
            } else if item == self!.sortingOptions[7] {
                self!.sortByRatingDecrease()
            } else if item == self!.sortingOptions[8] {
                self!.sortByLengtth()
            } else if item == self!.sortingOptions[9] {
                self!.sortByLengtthDecrease()
            }
        }
    }
}
extension RoutesPageRouteController {
    func sortByName() {
        routes = routes.sorted() { $0.title < $1.title }
        tableView.reloadData()
    }

    func sortByNameReverse() {
        routes = routes.sorted() { $0.title > $1.title }
        tableView.reloadData()
    }
    
    func sortByNearest() {
        guard let loc = currentLocation else {
            return
        }
        routes = routes.sorted() {
            CLLocationCoordinate2D(latitude: $0.places.first!.latitude, longitude: $0.places.first!.longitude).distance(from: loc) < CLLocationCoordinate2D(latitude: $0.places.first!.latitude, longitude: $1.places.first!.longitude).distance(from: loc)
        }
        tableView.reloadData()
    }
        
    func sortByFarest() {
        guard let loc = currentLocation else {
            return
        }
        routes = routes.sorted() {
            CLLocationCoordinate2D(latitude: $0.places.first!.latitude, longitude: $0.places.first!.longitude).distance(from: loc) > CLLocationCoordinate2D(latitude: $0.places.first!.latitude, longitude: $1.places.first!.longitude).distance(from: loc)
        }
        tableView.reloadData()
    }
    
    func sortByNumberOfLocations() {
        routes = routes.sorted() { $0.places.count > $1.places.count }
        tableView.reloadData()
    }
    
    func sortByNumberOfLocationsReverse() {
        routes = routes.sorted() { $0.places.count < $1.places.count }
        tableView.reloadData()
    }
    
    func sortByRating() {
        routes = routes.sorted() { Double($0.ratingsAvg ?? "0")! > Double($1.ratingsAvg ?? "0")! }
        tableView.reloadData()
    }
    
    func sortByRatingDecrease() {
        routes = routes.sorted() { Double($0.ratingsAvg ?? "0")! < Double($1.ratingsAvg ?? "0")! }
        tableView.reloadData()
    }
    
    func sortByLengtth() {
        routes = routes.sorted() { ($0.length ?? 0) > ($1.length ?? 0) }
        tableView.reloadData()
    }
    
    func sortByLengtthDecrease() {
        routes = routes.sorted() { ($0.length ?? 0) < ($1.length ?? 0) }
        tableView.reloadData()
    }
}

extension RoutesPageRouteController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        routes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = routes[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Cells.routeRoutesCell) as! RoutesPageRouteCell
        cell.setup(item)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let storyboard = UIStoryboard(name: Constants.Controllers.commentsMapController, bundle: nil)
        let next = storyboard.instantiateViewController(withIdentifier: Constants.Controllers.commentsMapController) as! CommentsMapController
        next.locations = routes[indexPath.row].places
        next.routeId = routes[indexPath.row].id
        self.navigationController?.pushViewController(next, animated: true)
    }
}

extension RoutesPageRouteController: CLLocationManagerDelegate {
    func setupLocation() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
    }
        
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = manager.location?.coordinate else { return }
        currentLocation = location
    }
}
