//
//  KeyValueTableViewCell.swift
//  SpotifyAPI
//
//  Created by Alexander Georgii-Hemming Cyon on 24/08/16.
//  Copyright © 2016 com.cyon. All rights reserved.
//

import UIKit

class KeyValueTableViewCell: UITableViewCell {
    @IBOutlet weak var keyLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!

    func configure(withKey key: String, value: String) {
        self.keyLabel.text = key
        self.valueLabel.text = value
    }
}
