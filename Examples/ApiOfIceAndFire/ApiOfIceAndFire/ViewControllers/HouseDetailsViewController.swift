//
//  HouseDetailsViewController.swift
//  ApiOfIceAndFire
//
//  Created by Cyon Alexander (Ext. Netlight) on 23/08/16.
//  Copyright © 2016 com.cyon. All rights reserved.
//

import UIKit

private let cellIdentifier = "cellIdSetInStoryboard"
private let attributeCountExceptMembers = 4
class HouseDetailsViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!

    private var house: House!

    static func instantiate(withHouse house: House) -> HouseDetailsViewController {
        let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("houseDetails") as! HouseDetailsViewController
        viewController.house = house
        return viewController
    }

}

//MARK: UITableViewDataSource Methods
extension HouseDetailsViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath)
        if let cell = cell as? HouseInfoTableViewCell {
            let row = indexPath.row
            if row == 0 {
                cell.configure(withLabel: "Name", andInfo: house.name)
            } else if row == 1 {
                cell.configure(withLabel: "Words", andInfo: house.words)
            } else if row == 2 {
                cell.configure(withLabel: "Region", andInfo: house.region)
            } else if row == 3 {
                cell.configure(withLabel: "Coat of arms", andInfo: house.coatOfArms)
//            } else if row == 4 {
//                cell.configure(withLabel: "", andInfo: house.name)
//            } else if row == 5 {
//                cell.configure(withLabel: "Name", andInfo: house.name)
//            } else if row == 6 {
//                cell.configure(withLabel: "Name", andInfo: house.name)
            } else {
                let memberIdIndex = row - attributeCountExceptMembers
                guard let memberId = house.memberIds?[memberIdIndex] else { return cell }
                cell.configure(withLabel: "Member id", andInfo: memberId)
            }
        }
        return cell
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let rowCount = attributeCountExceptMembers + (house.memberIds?.count ?? 0)
        return rowCount
    }
}

extension HouseDetailsViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 50
    }
}

class HouseInfoTableViewCell: UITableViewCell {
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var info: UILabel!

    func configure(withLabel label: String, andInfo info: String?) {
        self.label.text = label
        self.info.text = info
    }
}