//
//  ArtistViewController.swift
//  SpotifyAPI
//
//  Created by Cyon Alexander (Ext. Netlight) on 30/08/16.
//  Copyright © 2016 com.cyon. All rights reserved.
//

import UIKit

class ArtistViewController: UIViewController {

    //MARK: Variables
    @IBOutlet weak var tableView: UITableView!

    //MARK: VC Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }

}

//MARK: UITableViewDataSource Methods
extension ArtistViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 0
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
fatalError()
        //let cell = tableView.dequeueReusableCell(withIdentifier: <#T##String#>, for: <#T##IndexPath#>)
    }
}

//MARK: UITableViewDelegate Methods
extension ArtistViewController: UITableViewDelegate {

}

//MARK: Private Methods
private extension ArtistViewController {
    func setupViews() {

    }
}
