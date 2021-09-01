//
//  ViewController.swift
//  NewKyivTourism
//
//  Created by Andrew on 30.05.2021.
//

import UIKit
import InfiniteCarouselCollectionView
import CoreLocation
import FaveButton
import GoogleSignIn

class MainPage: UITableViewController {
    @IBOutlet weak var menuBarButton: UIBarButtonItem!
    @IBOutlet weak var carousel: CarouselCollectionView!
    
    var sections: Array<String> = []
    var favourites: Array<LocationModel> = []
    
    let locationManager = CLLocationManager()
    let likeTable = LikeTable()
    
    var mainData: MainPageModel = MainPageModel(places: [], routes: [], posters: [])

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setMenu(menuBarButton)
        requestLocation()
        setupCarousel()
        registerCells()
        loadData()
    }
    
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
}

extension MainPage {
    private func loadData() {
        createSpinnerView {
            Network.sendRequest(endpoint: .main, data: nil, type: MainPageResponse.self) { result in
                switch result {
                case .success(let response):
                    self.setData(response)
                    break
                case .failure(let error):
                    self.loadAlert(error.localizedDescription) {
                        self.loadData()
                    }
                    break
                }
            }
        }
    }
    
    private func setData(_ data: MainPageResponse) {
        self.sections = [NSLocalizedString("Locations", comment: ""),
                         NSLocalizedString("Show bill", comment: "")]
        self.mainData = data.data
        self.tableView.reloadData()
        self.carousel.reloadData()
    }
    
    //MARK: Carousel setup
    private func setupCarousel() {
        carousel.bounds.size = CGSize(width: Constants.Metrics.width, height: Constants.Metrics.width  * 0.6)
        carousel.reloadData()
        carousel.carouselDataSource = self
        carousel.isAutoscrollEnabled = true
        carousel.autoscrollTimeInterval = 8.0
        carousel.flowLayout.itemSize = CGSize(width: Constants.Metrics.width, height: Constants.Metrics.width * 0.6)
    }
    
    //MARK: Cells setup
    private func registerCells() {
        tableView.register(UINib(nibName: Constants.Cells.mainPosterCell, bundle: nil), forCellReuseIdentifier: Constants.Cells.mainPosterCell)
        tableView.register(UINib(nibName: Constants.Cells.mainLocationCell, bundle: nil), forCellReuseIdentifier: Constants.Cells.mainLocationCell)
        carousel.register(UINib(nibName: Constants.Cells.mainRouteCell, bundle: nil), forCellWithReuseIdentifier: Constants.Cells.mainRouteCell)
    }
    
    //MARK: -Request for user location
    private func requestLocation() {
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.requestWhenInUseAuthorization()
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
                    self.favourites.append(self.mainData.places.first(where: { (i) -> Bool in
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

extension MainPage {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: Constants.Metrics.width, height: 50))
        let label = UILabel(frame: CGRect(x: 0, y: 10, width: Constants.Metrics.width, height: 30))
        label.text = sections[section]
        label.font = .systemFont(ofSize: 20)
        label.textAlignment = .center
        view.addSubview(label)
        view.backgroundColor = self.view.backgroundColor
        return view
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return mainData.places.count
        } else if section == 1 {
            return mainData.posters.count
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Constants.Metrics.width
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Cells.mainLocationCell) as! MainPageLocationCell
            let item = mainData.places[indexPath.row]
            cell.setup(item: item, favourites: favourites)
            cell.heartButton.addTarget(self, action: #selector(likeAction(_:)), for: .touchUpInside)
            return cell
        } else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Cells.mainPosterCell) as! MainPagePosterCell
            let item = mainData.posters[indexPath.row]
            cell.setup(item: item)
            return cell
        } else {
            let cell = UITableViewCell()
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 1 {
            let item = mainData.posters[indexPath.row]
            showPosterController(item: item)
        } else {
            let item = mainData.places[indexPath.row]
            showLocationController(item: item)
        }
    }
}

extension MainPage: CarouselCollectionViewDataSource {
    var numberOfItems: Int {
        return mainData.routes.count
    }
    
    func carouselCollectionView(_ carouselCollectionView: CarouselCollectionView, cellForItemAt index: Int, fakeIndexPath: IndexPath) -> UICollectionViewCell {
        let cell = carousel.dequeueReusableCell(withReuseIdentifier: Constants.Cells.mainRouteCell, for: fakeIndexPath) as! MainPageRouteCell
        let item = mainData.routes[index]
        cell.setup(item, index, "\(index + 1)/\(mainData.routes.count)")
        return cell
    }
    
    func carouselCollectionView(_ carouselCollectionView: CarouselCollectionView, didSelectItemAt index: Int) {
        let item = mainData.routes[index]
        showRouteController(item: item)
    }
}
