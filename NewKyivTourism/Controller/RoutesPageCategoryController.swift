//
//  RoutesPageCategoryController.swift
//  NewKyivTourism
//
//  Created by Andrew on 03.06.2021.
//

import Foundation

class RoutesPageCategoryController: UITableViewController {

    var categories: Array<CategoryModel> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.register(UINib(nibName: Constants.Cells.categoryCell, bundle: nil), forCellReuseIdentifier: Constants.Cells.categoryCell)
        loadData()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Cells.categoryCell, for: indexPath) as! RoutesPageCategoryCell
        cell.categoryImage.image = UIImage(named: "kyiv\(indexPath.row + 1)")
        cell.categoryImage.roundCorner()
        cell.categoryName.text = categories[indexPath.row].title
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Constants.Metrics.width / 2
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = categories[indexPath.row]
        showRoutesPageCategoryLocation(item: item)
    }
}

extension RoutesPageCategoryController {
    func loadData() {
        createSpinnerView {
            Network.sendRequest(endpoint: .category, data: nil, type: CategoryResponse.self) { result in
                switch result {
                case .success(let response):
                    self.categories = response.data
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
}
