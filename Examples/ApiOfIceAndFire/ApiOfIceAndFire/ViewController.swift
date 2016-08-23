//
//  ViewController.swift
//  ApiOfIceAndFire
//
//  Created by Alexander Georgii-Hemming Cyon on 20/08/16.
//  Copyright © 2016 com.cyon. All rights reserved.
//
import UIKit
import Zeus

class ViewController: UIViewController {

    private lazy var apiClient: APIClientProtocol = {
        let apiClient = APIClient.sharedInstance
        return apiClient
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        fetchData()
    }

}

private extension ViewController {
    private func fetchData() {
        apiClient.getHouses(queryParams: nil) {
            result in
            if let error = result.error {
                print("Error fetching houses, error: \(error)")
            } else if let houses = result.data as? [House] {
                print("successfully fetched #\(houses.count) houses")
            }
        }
    }
}

