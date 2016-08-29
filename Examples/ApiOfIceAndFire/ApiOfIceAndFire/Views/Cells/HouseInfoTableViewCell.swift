//
//  HouseInfoTableViewCell.swift
//  ApiOfIceAndFire
//
//  Created by Alexander Georgii-Hemming Cyon on 24/08/16.
//  Copyright © 2016 com.cyon. All rights reserved.
//

import UIKit

class HouseInfoTableViewCell: UITableViewCell {
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var info: UILabel!

    func configure(withLabel label: String, andInfo info: String) {
        self.label.text = label
        self.info.text = info
    }
}
