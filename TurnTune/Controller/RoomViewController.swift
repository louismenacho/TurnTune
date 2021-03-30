//
//  RoomViewController.swift
//  TurnTune
//
//  Created by Louis Menacho on 12/23/20.
//

import UIKit

class RoomViewController: UIViewController {
    
    var roomViewModel: RoomViewModel!
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var playbackStateLabel: UILabel!
    @IBOutlet weak var artworkImage: UIImageView!
    @IBOutlet weak var songName: UILabel!
    @IBOutlet weak var artistName: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = roomViewModel.roomDocumentRef.documentID
        navigationController!.navigationBar.standardAppearance.shadowColor = .clear
        navigationItem.hidesBackButton = true
        navigationItem.hidesSearchBarWhenScrolling = false
        navigationItem.searchController = prepareSearchController()
        roomViewModel.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationItem.hidesSearchBarWhenScrolling = true
    }
    
    private func prepareSearchController() -> UISearchController {
        let searchResultsViewController = prepareSearchResultsViewController()
        let searchController = UISearchController(searchResultsController: searchResultsViewController)
        searchController.searchResultsUpdater = searchResultsViewController
        searchController.delegate = self
        searchController.searchBar.autocapitalizationType = .none
        searchController.searchBar.placeholder = "Search songs"
        return searchController
    }
    
    private func prepareSearchResultsViewController() -> SearchResultsViewController {
        guard let searchResultsViewController = storyboard?.instantiateViewController(identifier: "SearchResultsViewController") as? SearchResultsViewController else {
            fatalError("Could not instantiate SearchResultsViewController")
        }
        searchResultsViewController.searcherViewModel = SearcherViewModel()
        searchResultsViewController.roomViewModel = roomViewModel
        return searchResultsViewController
    }
    
    @IBAction func play(_ sender: UIBarButtonItem) {
//        if let selectedSong = roomViewModel.currentMember?.selectedSong {
//            roomViewModel.setAndPlaySelectedSong(selectedSong, for: roomViewModel.currentMember!)
//        } else {
//            DispatchQueue.main.async {
//                self.navigationItem.searchController?.searchBar.becomeFirstResponder()
//            }
//        }
        APIClient<SpotifyPlayerAPI>().request(.playTrack(uris: [""])) { (result: Result<SearchResponse, Error>) in
            print("playTrack request")
            print(try? result.get())
        }
    }
    
    @IBAction func pause(_ sender: Any) {
//        SpotifyPlayer.shared.pausePlayback()
        APIClient<SpotifyPlayerAPI>().request(.pausePlayback) { (result: Result<SearchResponse, Error>) in
            print("pausePlayback request")
            print(try? result.get())
        }

    }
    
    @IBAction func disconnectPressed(_ sender: UIBarButtonItem) {
        SpotifyAppRemote.shared.disconnect()
    }
    
    @IBAction func connectButtonPressed(_ sender: UIBarButtonItem) {
//        SpotifyAppRemote.shared.connect()
        APIClient<SpotifyPlayerAPI>().request(.currentlyPlayingTrack) { (result: Result<SearchResponse, Error>) in
            print("currentlyPlayingTrack")
            print(try? result.get())
        }

    }
}



// MARK: - RoomViewModelDelegate
extension RoomViewController: RoomViewModelDelegate {
        
    func roomViewModel(roomViewModel: RoomViewModel, didInitialize: Bool) {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.reloadData()
    }
    
    func roomViewModel(roomViewModel: RoomViewModel, didUpdate room: Room) {
        playbackStateLabel.text = roomViewModel.isCurrentMemberTurn ? "Your turn" : "Now playing"
        
        guard let playingSong = room.playingSong else { return }
        songName.text = playingSong.name
        artistName.text = playingSong.artistName
        if
            let artworkURL = URL(string: playingSong.artworkURL),
            let imageData = try? Data(contentsOf: artworkURL)
        {
            artworkImage.image = UIImage(data: imageData)
        }
    }
    
    func roomViewModel(roomViewModel: RoomViewModel, didUpdate members: [Member]) {
        collectionView.reloadData()
    }
    
    func roomViewModel(roomViewModel: RoomViewModel, didUpdate queue: [Song]) {
        print("Queue Count: \(queue.count)")
    }
}



// MARK: - UISearchControllerDelegate
extension RoomViewController: UISearchControllerDelegate {
    func presentSearchController(_ searchController: UISearchController) {
        searchController.showsSearchResultsController = true
    }
}



// MARK: - UICollectionViewDataSource
extension RoomViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return roomViewModel.members.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MemberCollectionViewCell", for: indexPath) as! MemberCollectionViewCell
        cell.nameLabel.text = roomViewModel.members[indexPath.row].displayName
        return cell
    }
}



// MARK: - UICollectionViewDelegate
extension RoomViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
    }
}
