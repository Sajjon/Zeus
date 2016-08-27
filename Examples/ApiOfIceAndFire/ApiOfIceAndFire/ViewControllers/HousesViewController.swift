//
//  ViewController.swift
//  ApiOfIceAndFire
//
//  Created by Alexander Georgii-Hemming Cyon on 20/08/16.
//  Copyright © 2016 com.cyon. All rights reserved.
//
import UIKit
import Zeus
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}


private let cellIdentifier = "cellId"
class HousesViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    fileprivate var houses: [House]? {
        didSet { tableView.reloadData() }
    }

    fileprivate lazy var apiClient: APIClientProtocol = {
        let apiClient = APIClient.sharedInstance
        return apiClient
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        fetchData()
    }
}


//MARK: UITableViewDataSource Methods
extension HousesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        guard let house = house(forIndexPath: indexPath) else { return cell }
        cell.textLabel?.text = house.name
        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let rowCount = houses?.count ?? 0
        return rowCount
    }
}

//MARK: UITableViewDelegate Methods
extension HousesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let house = house(forIndexPath: indexPath) else { return }
        let detailsViewController = HouseDetailsViewController.instantiate(withHouse: house)
        navigationController?.pushViewController(detailsViewController, animated: true)
    }
}

//MARK: Private Methods
private extension HousesViewController {

    func setupViews() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
    }

    func fetchData() {
        apiClient.getHouses(queryParams: ["pageSize":"500"]) {
            result in
            if let error = result.error {
                print("Error fetching houses, error: \(error)")
            } else if let houses = result.data as? [House] {
                print("successfully fetched #\(houses.count) houses")
                self.houses = houses
            }
        }
    }

    func house(forIndexPath indexPath: IndexPath) -> House? {
        guard ((indexPath as NSIndexPath).row < houses?.count) == true else { return nil }
        let house = houses?[(indexPath as NSIndexPath).row]
        return house
    }
}
