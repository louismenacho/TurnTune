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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        navigationItem.searchController = prepareSearchController()
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.title = vm.session.id
        
        vm.sessionChangeListener { result in
            switch result {
            case .failure(let error):
                print(error)
            case .success(let session):
                print("session updated")
                self.searchViewController.vm.updateSpotifyToken(session.spotifyToken)
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SessionDetailsViewController" {
            let vc = segue.destination as! SessionDetailsViewController
            vc.vm = SessionDetailsViewModel(vm.session)
        }
    }
    
    private func prepareSearchController() -> UISearchController? {
        searchViewController = storyboard?.instantiateViewController(identifier: "SearchViewController") as? SearchViewController
        searchViewController.vm = SearchViewModel(vm.session.spotifyToken)
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
        performSegue(withIdentifier: "SessionDetailsViewController", sender: self)
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
        vm.renewSpotifyToken { [self] result in
            switch result {
            case .success:
                vm.updateSession { result in
                    if case let .failure(error) = result {
                        print(error)
                    }
                }
            case .failure(let error):
                print(error)
            }
        }
    }
}
