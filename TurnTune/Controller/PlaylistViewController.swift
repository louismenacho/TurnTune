//
//  PlaylistViewController.swift
//  TurnTune
//
//  Created by Louis Menacho on 11/14/21.
//

import UIKit

class PlaylistViewController: UIViewController {
    
    var vm: PlaylistViewModel!
    var searchViewController: SearchViewController!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var playButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.searchController = prepareSearchController()
        navigationItem.hidesSearchBarWhenScrolling = false
        tableView.dataSource = self
        tableView.delegate = self
        playButton.isHidden = !vm.isCurrentUserHost()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.title = vm.room.id
        
        vm.roomChangeListener { result in
            switch result {
            case .failure(let error):
                print(error)
            case .success(let room):
                print("room updated")
                self.searchViewController.vm.updateSpotifyToken(room.spotifyToken)
            }
        }
        
        vm.playlistChangeListener { result in
            switch result {
            case .failure(let error):
                print(error)
            case .success:
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        vm.removeRoomChangeListener()
        vm.removePlaylistChangeListener()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "RoomDetailsViewController" {
            let vc = segue.destination as! RoomDetailsViewController
            vc.vm = RoomDetailsViewModel(vm.room)
        }
    }
    
    @IBAction func playButtonPressed(_ sender: UIButton) {
        vm.wakeAndPlay { result in
            if case .failure(let error) = result {
                print(error)
            }
        }
    }
    
    private func prepareSearchController() -> UISearchController? {
        searchViewController = storyboard?.instantiateViewController(identifier: "SearchViewController") as? SearchViewController
        searchViewController.vm = SearchViewModel(vm.room.spotifyToken)
        searchViewController.delegate = self
        
        let searchController = UISearchController(searchResultsController: searchViewController)
        searchController.searchResultsUpdater = searchViewController
        searchController.searchBar.placeholder = "Search songs"
        searchController.searchBar.autocapitalizationType = .none
        searchController.searchBar.setValue("Done", forKey: "cancelButtonText")
        searchController.delegate = self
        return searchController
    }
    
    @IBAction func sessionDetailsButtonPressed(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "RoomDetailsViewController", sender: self)
    }
}

extension PlaylistViewController: UISearchControllerDelegate {
    
    func presentSearchController(_ searchController: UISearchController) {
        searchController.showsSearchResultsController = true
    }
}

extension PlaylistViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        vm.playlist.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PlaylistTableViewCell", for: indexPath) as? PlaylistTableViewCell else {
            return UITableViewCell()
        }
        cell.song = vm.playlist[indexPath.row]
        return cell
    }
}

extension PlaylistViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension PlaylistViewController: SearchViewControllerDelegate {
    func searchViewController(_ searchViewController: SearchViewController, didAdd song: Song) {
        vm.addSong(song) { result in
            if case .failure(let error) = result {
                print(error)
            }
        }
    }
    
    func searchViewController(_ searchViewController: SearchViewController, renewSpotifyToken: Void) {
        vm.renewSpotifyToken { result in
            if case .failure(let error) = result {
                print(error)
            } else {
                print("renewSpotifyToken completed")
            }
        }
    }
}
