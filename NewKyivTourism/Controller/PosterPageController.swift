//
//  PosterPageController.swift
//  NewKyivTourism
//
//  Created by Andrew on 25.06.2021.
//

import Foundation
import Alamofire
import AlamofireImage

class PosterPageController: UITableViewController {
    @IBOutlet weak var menuBarButton: UIBarButtonItem!
    var posters: Array<PosterModel> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.register(UINib(nibName: Constants.Cells.mainPosterCell, bundle: nil), forCellReuseIdentifier: Constants.Cells.mainPosterCell)
        self.setMenu(menuBarButton)
        loadData()
    }
    
    func loadData() {
        createSpinnerView {
            Network.sendRequest(endpoint: .poster, data: nil, type: PosterResponse.self) { result in
                switch result {
                case .success(let response):
                    self.posters = response.data
                    self.tableView.reloadData()
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
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posters.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Constants.Metrics.width
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Cells.mainPosterCell) as! MainPagePosterCell
        let item = posters[indexPath.row]
        cell.setup(item: item)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = posters[indexPath.row]
        let storyboard = UIStoryboard(name: Constants.Controllers.posterDetailController, bundle: nil)
        let nextViewController = storyboard.instantiateViewController(identifier: Constants.Controllers.posterDetailController)as! PosterDetailController
        nextViewController.posterData = item
        self.navigationController?.pushViewController(nextViewController, animated: true)
    }
}
