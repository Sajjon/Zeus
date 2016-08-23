//
//  ViewController.swift
//  ApiOfIceAndFire
//
//  Created by Alexander Georgii-Hemming Cyon on 20/08/16.
//  Copyright © 2016 com.cyon. All rights reserved.
//
import UIKit
import Zeus

private let cellIdentifier = "cellId"
class HousesViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    private var houses: [House]? {
        didSet { tableView.reloadData() }
    }

    private lazy var apiClient: APIClientProtocol = {
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
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath)
        guard let house = house(forIndexPath: indexPath) else { return cell }
        cell.textLabel?.text = house.name
        return cell
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let rowCount = houses?.count ?? 0
        return rowCount
    }
}

//MARK: UITableViewDelegate Methods
extension HousesViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        guard let house = house(forIndexPath: indexPath) else { return }
        let detailsViewController = HouseDetailsViewController.instantiate(withHouse: house)
        navigationController?.pushViewController(detailsViewController, animated: true)
    }
}

//MARK: Private Methods
private extension HousesViewController {

    private func setupViews() {
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
    }

    private func fetchData() {
        apiClient.getHouses(queryParams: ["pageSize":"50"]) {
            result in
            if let error = result.error {
                print("Error fetching houses, error: \(error)")
            } else if let houses = result.data as? [House] {
                print("successfully fetched #\(houses.count) houses")
                self.houses = houses
            }
        }
    }

    private func house(forIndexPath indexPath: NSIndexPath) -> House? {
        guard (indexPath.row < houses?.count) == true else { return nil }
        let house = houses?[indexPath.row]
        return house
    }
}