//
//  GlobalSearchController.swift
//  NewKyivTourism
//
//  Created by Andrew on 31.05.2021.
//

import Foundation

class GlobalSearchController: UITableViewController {
    @IBOutlet weak var searchBar: UISearchBar!
    
    let cellName = "cell"
    var data: MainPageModel = MainPageModel(places: [], routes: [], posters: [])
    var sectionsArray: Array<String> = []
    var isSearching = false
    
    let locationSection = NSLocalizedString("Locations", comment: "")
    let routeSection = NSLocalizedString("Routes", comment: "")
    let posterSection = NSLocalizedString("Show bill", comment: "")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.placeholder = NSLocalizedString("Input Location, Show Bill or Route", comment: "")
        searchBar.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellName)
    }
    
    func loadData(info: String) {
        let dictionary = ["search" : info]
        let data = try! JSONEncoder().encode(dictionary)
        Network.sendRequest(endpoint: .allData, data: data, type: MainPageResponse.self) { result in
            switch result {
            case .success(let response):
                let data = response.data
                self.data = data
                self.sectionsArray = []
                if data.places.count != 0 {
                    self.sectionsArray.append(self.locationSection)
                }
                if data.routes.count != 0 {
                    self.sectionsArray.append(self.routeSection)
                }
                if data.posters.count != 0 {
                    self.sectionsArray.append(self.posterSection)
                }
                self.tableView.reloadData()
                break
            case .failure(let error):
                self.emptyMessage(message: error.localizedDescription)
                break
            }
        }
    }
}

extension GlobalSearchController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar.endEditing(true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        isSearching = !searchText.isEmpty
        if isSearching {
            loadData(info: searchText)
        } else {
            sectionsArray = []
            data = MainPageModel(places: [], routes: [], posters: [])
            tableView.reloadData()
        }
    }
}

extension GlobalSearchController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        if sectionsArray.count == 0 && isSearching {
            self.emptyMessage(message: NSLocalizedString("Nothing found", comment: ""))
        } else {
            self.tableView.backgroundView = nil
            self.tableView.separatorStyle = .singleLine
        }
        return sectionsArray.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionName = sectionsArray[section]
        if sectionName == locationSection {
            return data.places.count
        } else if sectionName == routeSection {
            return data.routes.count
        } else if sectionName == posterSection {
            return data.posters.count
        } else {
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let sectionName = sectionsArray[section]
        return sectionName
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellName)!
        cell.textLabel?.numberOfLines = 0
        let sectionName = sectionsArray[indexPath.section]
        if sectionName == locationSection {
            let item = data.places[indexPath.row]
            cell.textLabel?.text = item.title
        } else if sectionName == routeSection {
            let item = data.routes[indexPath.row]
            cell.textLabel?.text = item.title
        } else if sectionName == posterSection {
            let item = data.posters[indexPath.row]
            cell.textLabel?.text = item.title
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
//        let sectionName = sectionsArray[indexPath.section]
//        if sectionName == locationSection {
//            let item = data.places[indexPath.row]
//            let storyboard = UIStoryboard(name: Constants.Controllers.locationDetailController, bundle: nil)
//            let nextViewController = storyboard.instantiateViewController(withIdentifier: Constants.Controllers.locationDetailController) as! LocationDetailController
//            nextViewController.locationInfo = item
//            navigationController?.pushViewController(nextViewController, animated: true)
//        }
//        else if sectionName == routeSection {
//            let item = data.routes[indexPath.row]
//            let storyboard = UIStoryboard(name: Constants.Controllers.commentsMapController, bundle: nil)
//            let nextViewController = storyboard.instantiateViewController(withIdentifier: Constants.Controllers.commentsMapController) as! CommentsMapController
//            nextViewController.locations = item.places
//            nextViewController.routeId = item.id
//            navigationController?.pushViewController(nextViewController, animated: true)
//        }
//        else if sectionName == posterSection {
//            let item = data.posters[indexPath.row]
//            let storyboard = UIStoryboard(name: Constants.Controllers.posterDetailController, bundle: nil)
//            let nextVC = storyboard.instantiateViewController(identifier: Constants.Controllers.posterDetailController) as! PosterDetailController
//            nextVC.posterData = item
//            navigationController?.pushViewController(nextVC, animated: true)
//        }
    }
}
