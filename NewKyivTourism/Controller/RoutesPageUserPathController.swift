//
//  RoutesPageUserPathController.swift
//  NewKyivTourism
//
//  Created by Andrew on 03.06.2021.
//

import Foundation
import UIKit
import RSSelectionMenu

class RoutesPageUserPathController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var filterButton: UIButton!
    @IBOutlet weak var buildRouteButton: UIButton!
    
    let ident = "buildPathSeguey"
    
    var shownLocations: Array<LocationModel> = []
    var locations: Array<LocationModel> = []
    var choosedLocation: Array<LocationModel> = []
    
    var categories: Array<CategoryModel> = []
    var filteredCategories: Array<CategoryModel> = []
            
    let stack: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 10
        sv.sizeToFit()
        return sv
    }()
    
    let notLoggedInLabel: UILabel = {
        let nlil = UILabel()
        nlil.text = NSLocalizedString("You are not authorized", comment: "")
        nlil.numberOfLines = 0
        nlil.textAlignment = .center
        nlil.textColor = .label
        return nlil
    }()
    
    let authorizeButton: UIButton = {
        let ab = UIButton()
        ab.setTitle(NSLocalizedString("Authorize", comment: ""), for: .normal)
        ab.addTarget(self, action: #selector(goToAuthorizationController), for: .touchUpInside)
        ab.setTitleColor(.systemBlue, for: .normal)
        return ab
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: Constants.Cells.buildPathCell, bundle: nil), forCellReuseIdentifier: Constants.Cells.buildPathCell)
    }
    
    @objc func goToAuthorizationController() {
//        let storyboard = UIStoryboard(name: Constants.Controllers.notLoggedInController, bundle: nil)
//        let nextViewController = storyboard.instantiateViewController(withIdentifier: "registrationForm") as! RegistrationForm
//        navigationController?.pushViewController(nextViewController, animated: true)
    }
}

extension RoutesPageUserPathController {
    func loadData() {
        userIsLoggedInCheck { (isLogged) in
            if isLogged {
                self.tableView.backgroundView = nil
                self.tableView.separatorStyle = .singleLine
                
                self.createSpinnerView {
                    self.loadFavourites()
                }
            } else {
                self.filterButton.isHidden = true
                self.buildRouteButton.isHidden = true
                
                self.stack.addArrangedSubview(self.notLoggedInLabel)
                self.stack.addArrangedSubview(self.authorizeButton)
                
                self.tableView.backgroundView = self.stack;
                self.tableView.separatorStyle = .none;
            }
        }
    }
    
    func loadFavourites() {
        Network.sendRequest(endpoint: .favourites, data: nil, type: LocationResponse.self) { (result) in
            switch result {
            case .failure(let error):
                self.loadAlert(error.localizedDescription) {
                    self.loadData()
                }
                break
            case .success(let data):
                self.setLocations(data)
                break
            }
        }
    }
    
    func setLocations(_ location: LocationResponse) {
        self.shownLocations = location.data
        self.locations = location.data
        if self.locations.count == 0 {
            
        }
        self.loadCategories()
    }
    
    func loadCategories() {
        Network.sendRequest(endpoint: .category, data: nil, type: CategoryResponse.self) { (result) in
            switch result {
            case .failure(let error):
                self.loadAlert(error.localizedDescription) {
                    self.loadData()
                }
                break
            case .success(let data):
                self.setCategories(data)
                break
            }
        }
    }
    
    func setCategories(_ categories: CategoryResponse) {
        self.categories = categories.data
        self.filteredCategories = categories.data
        self.tableView.reloadData()
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == ident {
            if choosedLocation.count == 0 {
                registrationAlert(NSLocalizedString("Choose at least one location", comment: ""))
                return false
            } else {
                return true
            }
        }
        return true
    }
    
    @IBAction func buildPath(_ sender: Any) {
        if choosedLocation.count > 0 {
            let storyboard = UIStoryboard(name: Constants.Controllers.noCommentsMapController, bundle: nil)
            let nextViewController = storyboard.instantiateViewController(withIdentifier: Constants.Controllers.noCommentsMapController) as! NoCommentsMapController
            nextViewController.locations = choosedLocation
            navigationController?.pushViewController(nextViewController, animated: true)
        }
    }
    
    @IBAction func filterArray(_ sender: Any) {
        let selectionMenu = RSSelectionMenu(selectionStyle: .multiple, dataSource: categories) { (cell, cat, indexPath) in
            cell.textLabel?.text = cat.title
        }
        
        selectionMenu.setSelectedItems(items: filteredCategories) { [weak self] (item, index, isSelected, selectedItems) in
            self?.filteredCategories = selectedItems
        }
        
        selectionMenu.cellSelectionStyle = .checkbox
        
        selectionMenu.show(style: .alert(title: NSLocalizedString("Select", comment: ""), action: nil, height: nil), from: self)
        
        selectionMenu.dismissAutomatically = false
        
        selectionMenu.onDismiss = { [weak self] selectedItems in
            self?.filteredCategories = selectedItems
            
            self?.shownLocations = self!.locations
            
            self?.shownLocations = (self?.shownLocations.filter { (item) -> Bool in
                return (self?.filteredCategories.contains(where: { (i) -> Bool in
                    return item.catId == i.id
                }))!
            })!
            self?.tableView.reloadData()
        }
    }
}

extension RoutesPageUserPathController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Constants.Metrics.width / 2
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.shownLocations.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: Constants.Cells.buildPathCell) as! RoutesPageUserPathCell
        let item = shownLocations[indexPath.row]
        cell.setup(item: item)
        cell.checked.isHidden = !choosedLocation.contains(where: { (i) -> Bool in
            return i.id == item.id
        })
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = shownLocations[indexPath.row]
        if choosedLocation.contains(where: { (i) -> Bool in
            return i.id == item.id
        }) {
            choosedLocation.removeAll { (i) -> Bool in
                return i.id == item.id
            }
        } else {
            choosedLocation.append(item)
        }
        tableView.deselectRow(at: indexPath, animated: true)
        tableView.reloadData()
    }
}
