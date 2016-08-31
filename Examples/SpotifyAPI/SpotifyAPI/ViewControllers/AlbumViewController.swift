//
//  AlbumViewController.swift
//  SpotifyAPI
//
//  Created by Cyon Alexander (Ext. Netlight) on 31/08/16.
//  Copyright © 2016 com.cyon. All rights reserved.
//

import UIKit

private let cellIdentifier = "cellId"
class AlbumViewController: UIViewController {

    //MARK: Variables
    @IBOutlet weak var tableView: UITableView!

    var albumId: String!

    fileprivate var album: Album? {
        didSet {
            guard album != nil else { return }
            tableView.reloadData()
        }
    }

    static func instantiate(withAlbum album: Album) -> AlbumViewController {
        let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "album") as! AlbumViewController
        viewController.albumId = album.albumId
        return viewController
    }

    //MARK: VC Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchData()
    }

}

//MARK: UITableViewDataSource Methods
extension AlbumViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        guard album != nil else { return 0 }
        return 4
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var rowCount = 0
        //        if section == 0 {
        //            rowCount = 6
        //        } else if section == 1 {
        //            rowCount = artist?.genres?.count ?? 0
        //        } else if section == 2 {
        //            rowCount = artist?.images?.count ?? 0
        //        } else if section == 3 {
        //            rowCount = artist?.albums?.count ?? 0
        //        }
        return rowCount
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        if let cell = cell as? KeyValueTableViewCell, let pair = keyValue(for: indexPath) {
            cell.configure(withKey: pair.key, value: pair.value)
        }
        return cell
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var title: String?
        if section == 0 {
            title = "About"
        } else if section == 1 {
            title = "Images"
        } else if section == 2 {
            title = "Available markets"
        } else if section == 3 {
            title = "Albums"
        }
        return title
    }
}

//MARK: UITableViewDelegate Methods
extension AlbumViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let height = KeyValueTableViewCell.height
        return height
    }
}

//MARK: Private Methods
private extension AlbumViewController {
    func setupViews() {
        tableView.register(UINib.init(nibName: KeyValueTableViewCell.className, bundle: nil) , forCellReuseIdentifier: cellIdentifier)
    }

    func fetchData() {
        APIClient.sharedInstance.getAlbum(byId: albumId, queryParams: nil) {
            result in
            switch result {
            case .success(let data):
                guard let album = data as? Album else { break }
                self.album = album
            case .failure(let error):
                print("Failed to get artist, error: \(error)")
            }
        }
    }


    func keyValue(for indexPath: IndexPath) -> KeyValuePair? {
        guard let album = album else { return nil }
        let section = indexPath.section
        let row = indexPath.row
        var pair: KeyValuePair?
        if section == 0 {
            if row == 0 {
                pair = KeyValuePair("Id", album.albumId)
            } else if row == 1 {
                pair = KeyValuePair("Name", album.name)
            } else if row == 2 {
                pair = KeyValuePair("Href", album.href)
            } else if row == 3 {
                pair = KeyValuePair("Uri", album.uri)
            } else if row == 4 {
                pair = KeyValuePair("Release data", album.releaseDateString)
            } else if row == 5 {
                pair = KeyValuePair("Popularity", album.popularity)
            }
        } else if section == 1 {
            guard let images = album.images, row < images.count else { return nil }
            let image: Image = images[row]
            pair = KeyValuePair("Image url", image.url)
        } else if section == 2 {
            guard row < album.availableMarkets.count else { return nil }
            let market = album.availableMarkets[row]
            pair = KeyValuePair("Market", market)
        } else if section == 3 {
            guard let tracks = album.tracks, row < tracks.count else { return nil }
            let track: Track = tracks[row]
            pair = KeyValuePair(track.number, track.name)
        }
        return pair
    }
}
