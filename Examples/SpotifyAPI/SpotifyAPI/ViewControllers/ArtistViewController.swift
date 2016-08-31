//
//  ArtistViewController.swift
//  SpotifyAPI
//
//  Created by Cyon Alexander (Ext. Netlight) on 30/08/16.
//  Copyright © 2016 com.cyon. All rights reserved.
//

import UIKit

private let cellIdentifier = "artistCellId"
private let depecheMode = "762310PdDnwsDxAQxzQkfX"
class ArtistViewController: UIViewController {

    //MARK: Variables
    @IBOutlet weak var tableView: UITableView!
    fileprivate var artist: Artist? {
        didSet {
            guard artist != nil else { return }
            tableView.reloadData()
        }
    }

    //MARK: VC Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        fetchData()
    }

}

//MARK: UITableViewDataSource Methods
extension ArtistViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        guard artist != nil else { return 0 }
        return 4
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var rowCount = 0
        if section == 0 {
            rowCount = 5
        } else if section == 1 {
            rowCount = artist?.genres?.count ?? 0
        } else if section == 2 {
            rowCount = artist?.images?.count ?? 0
        } else if section == 3 {
            rowCount = artist?.albums?.count ?? 0
        }
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
            title = "Genres"
        } else if section == 2 {
            title = "Images"
        } else if section == 3 {
            title = "Albums"
        }
        return title
    }
}

//MARK: UITableViewDelegate Methods
extension ArtistViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let height = KeyValueTableViewCell.height
        return height
    }
}

//MARK: Private Methods
private extension ArtistViewController {
    func setupViews() {
        tableView.register(UINib.init(nibName: KeyValueTableViewCell.className, bundle: nil) , forCellReuseIdentifier: cellIdentifier)
    }

    func fetchData() {
        APIClient.sharedInstance.getArtist(byId: depecheMode, queryParams: nil) {
            result in
            switch result {
            case .success(let data):
                guard let artist = data as? Artist else { break }
                self.artist = artist
                self.fetchAlbums(forArtist: artist)
            case .failure(let error):
                print("Failed to get artist, error: \(error)")
            }
        }
    }

    func fetchAlbums(forArtist artist: Artist) {
        let params = ["offset" : "0", "limit": "50"]
        APIClient.sharedInstance.getAlbums(byArtist: artist.artistId, queryParams: params) {
            result in
            switch result {
            case .success(let data):
                guard let albums = data as? [Album] else { break }
                self.artist?.albums = albums
                self.tableView.reloadData()
            case .failure(let error):
                print("Failed to get albums for artist, error: \(error)")
            }
        }
    }

    func keyValue(for indexPath: IndexPath) -> KeyValuePair? {
        guard let artist = artist else { return nil }
        let section = indexPath.section
        let row = indexPath.row
        var pair: KeyValuePair?
        if section == 0 {
            if row == 0 {
                pair = KeyValuePair("Id", artist.artistId)
            } else if row == 1 {
                pair = KeyValuePair("Name", artist.name)
            } else if row == 2 {
                pair = KeyValuePair("Type", artist.type)
            } else if row == 3 {
                pair = KeyValuePair("Followers", artist.followers)
            } else if row == 4 {
                pair = KeyValuePair("Popularity", artist.popularity)
            }
        } else if section == 1 {
            guard let genres = artist.genres, row < genres.count else { return nil }
            let genre = genres[row]
            pair = KeyValuePair(genre, nil)
        } else if section == 2 {
            guard let images = artist.images, row < images.count else { return nil }
            let image: Image = images[row]
            pair = KeyValuePair("Image url", image.url)
        } else if section == 3 {
            guard let albums = artist.albums, row < albums.count else { return nil }
            let album = albums[row]
            pair = KeyValuePair(album.name, nil)
        }
        return pair
    }
}

struct KeyValuePair {
    let key: String?
    let value: String?
    init(_ key: String?, _ value: Any?) {
        self.key = key
        if let stringValue = value as? String {
            self.value = stringValue
        } else if let other = value {
            self.value = "\(other)"
        } else {
            self.value = nil
        }
    }
}
