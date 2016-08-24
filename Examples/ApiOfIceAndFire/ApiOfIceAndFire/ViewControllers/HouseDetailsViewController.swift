//
//  HouseDetailsViewController.swift
//  ApiOfIceAndFire
//
//  Created by Cyon Alexander (Ext. Netlight) on 23/08/16.
//  Copyright © 2016 com.cyon. All rights reserved.
//

import UIKit

private let cellIdentifier = "cellIdSetInStoryboard"
class HouseDetailsViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!

    private var house: House!
    private var characters: [Character]? {
        return house.members
    }
    private var cadetBranches: [House]? {
        return house.cadetBranches
    }

    static func instantiate(withHouse house: House) -> HouseDetailsViewController {
        let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("houseDetails") as! HouseDetailsViewController
        viewController.house = house
        return viewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        fetchMembers()
        fetchCadetBranches()
    }

}

//MARK: UITableViewDataSource Methods
extension HouseDetailsViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath)
        if let cell = cell as? HouseInfoTableViewCell {
            let row = indexPath.row
            if indexPath.section == 0 {
                if row == 0 {
                    cell.configure(withLabel: "Id", andInfo: house.houseId)
                } else if row == 1 {
                    cell.configure(withLabel: "Name", andInfo: house.name)
                } else if row == 2 {
                    cell.configure(withLabel: "Words", andInfo: house.words)
                } else if row == 3 {
                    cell.configure(withLabel: "Region", andInfo: house.region)
                } else if row == 4 {
                    cell.configure(withLabel: "Coat of arms", andInfo: house.coatOfArms)
                }
            } else if indexPath.section == 1 {
                if let member = characterAtIndex(row) {
                    cell.configure(withLabel: "Member", andInfo: member.name)
                } else {
                    guard let memberId = house.memberIds?[row] else { return cell }
                    cell.configure(withLabel: "Member id", andInfo: memberId)
                }
            } else if indexPath.section == 2 {
                if let cadetBranch = cadetBranchAtIndex(row) {
                    cell.configure(withLabel: "House", andInfo: cadetBranch.name)
                } else {
                    guard let houseId = house.cadetBranchIds?[row] else { return cell }
                    cell.configure(withLabel: "House id", andInfo: houseId)
                }
            }
        }
        return cell
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 5
        } else if section == 1 {
            return house.memberIds?.count ?? 0
        } else if section == 2 {
            return house.cadetBranchIds?.count ?? 0
        }
        return 0
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }

    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "General Info"
        } else if section == 1 {
            return "Sworn members"
        } else if section == 2 {
            return "Cadet branches"
        }
        return ""
    }
}

//MARK: UITableViewDelegate Methods
extension HouseDetailsViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 50
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 2 {
            guard let house = cadetBranchAtIndex(indexPath.row) else { return }
            let viewController = HouseDetailsViewController.instantiate(withHouse: house)
            navigationController?.pushViewController(viewController, animated: true)
        }
    }
}

//MARK: Private Methods
private extension HouseDetailsViewController {
    private func fetchMembers() {
        guard let memberIds = house.memberIds else { return }
        for memberId in memberIds {
            APIClient.sharedInstance.getCharacter(byId: memberId, queryParams: nil) {
                result in
                if let error = result.error {
                    print("Error fetching character, error: \(error)")
                } else if let character = result.data as? Character {
                    self.tableView.reloadData()
                }
            }
        }
    }
    private func fetchCadetBranches() {
        guard let cadetBranchIds = house.cadetBranchIds else { return }
        for cadetBranchId in cadetBranchIds {
            APIClient.sharedInstance.getHouse(byId: cadetBranchId, queryParams: nil) {
                result in
                if let error = result.error {
                    print("Error fetching house, error: \(error)")
                } else if let house = result.data as? House {
                    self.tableView.reloadData()
                }
            }
        }
    }

    private func characterAtIndex(index: Int) -> Character? {
        guard (index < characters?.count) == true else { return nil }
        let character = characters?[index]
        return character
    }

    private func cadetBranchAtIndex(index: Int) -> House? {
        guard (index < cadetBranches?.count) == true else { return nil }
        let house = cadetBranches?[index]
        return house
    }

}