//
//  HouseDetailsViewController.swift
//  ApiOfIceAndFire
//
//  Created by Cyon Alexander (Ext. Netlight) on 23/08/16.
//  Copyright © 2016 com.cyon. All rights reserved.
//

import UIKit
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


private let cellIdentifier = "cellIdSetInStoryboard"
class HouseDetailsViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!

    fileprivate var house: House!
    fileprivate var characters: [Character]? {
        return house.members
    }
    fileprivate var cadetBranches: [House]? {
        return house.cadetBranches
    }

    static func instantiate(withHouse house: House) -> HouseDetailsViewController {
        let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "houseDetails") as! HouseDetailsViewController
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
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        if let cell = cell as? HouseInfoTableViewCell {
            let row = (indexPath as NSIndexPath).row
            if (indexPath as NSIndexPath).section == 0 {
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
            } else if (indexPath as NSIndexPath).section == 1 {
                if let member = characterAtIndex(row) {
                    cell.configure(withLabel: "Member", andInfo: member.name)
                } else {
                    guard let memberId = memberId(at: row) else { return cell }
                    cell.configure(withLabel: "Member id", andInfo: memberId)
                }
            } else if (indexPath as NSIndexPath).section == 2 {
                if let cadetBranch = cadetBranchAtIndex(row) {
                    cell.configure(withLabel: "House", andInfo: cadetBranch.name)
                } else {
                    guard let houseId = cadetBranchId(at: row) else { return cell }
                    cell.configure(withLabel: "House id", andInfo: houseId)
                }
            }
        }
        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 5
        } else if section == 1 {
            return house.memberIds.count
        } else if section == 2 {
            return house.cadetBranchIds.count
        }
        return 0
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
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
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath as NSIndexPath).section == 2 {
            guard let house = cadetBranchAtIndex((indexPath as NSIndexPath).row) else { return }
            let viewController = HouseDetailsViewController.instantiate(withHouse: house)
            navigationController?.pushViewController(viewController, animated: true)
        }
    }
}

//MARK: Private Methods
private extension HouseDetailsViewController {
    func fetchMembers() {
        for memberId in house.memberIds {
            APIClient.sharedInstance.getCharacter(byId: memberId, queryParams: nil) {
                result in
                switch result {
                case .success(let character):
                    if let character = character as? Character {
                        print("successfully fetched character named '\(character.name)'")
                        self.tableView.reloadData()
                    } else {fatalError("bah")}
                case .failure(let error):
                    print("Error fetching character, error: \(error)")
                }
            }
        }
    }
    func fetchCadetBranches() {
        for cadetBranchId in house.cadetBranchIds {
            APIClient.sharedInstance.getHouse(byId: cadetBranchId, queryParams: nil) {
                result in
                switch result {
                case .success(let house):
                    if let house = house as? House {
                        print("successfully fetched house named: '\(house.name)'")
                        self.tableView.reloadData()
                    } else {fatalError("bah")}
                case .failure(let error):
                    print("Error fetching house, error: \(error)")
                }
            }
        }
    }

    func memberId(at index: Int) -> String? {
        guard (index < house.memberIds.count) == true else { return nil }
        let memberId = house.memberIds[index]
        return memberId
    }

    func cadetBranchId(at index: Int) -> String? {
        guard (index < house.cadetBranchIds.count) == true else { return nil }
        let memberId = house.cadetBranchIds[index]
        return memberId
    }

    func characterAtIndex(_ index: Int) -> Character? {
        guard (index < characters?.count) == true else { return nil }
        let character = characters?[index]
        return character
    }

    func cadetBranchAtIndex(_ index: Int) -> House? {
        guard (index < cadetBranches?.count) == true else { return nil }
        let house = cadetBranches?[index]
        return house
    }

}
