//
//  PlaylistViewController.swift
//  TurnTune
//
//  Created by Louis Menacho on 11/14/21.
//

import UIKit

class PlaylistViewController: UIViewController {
    
    var vm: PlaylistViewModel!

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
        navigationItem.title = vm.session.code
    }
    
    private func prepareSearchController() -> UISearchController? {
        guard let session = vm.spotifySessionManager.session else {
            print("Spotify session is nil on prepareSearchController")
            return nil
        }
        let searchViewController = storyboard?.instantiateViewController(identifier: "SearchViewController") as! SearchViewController
        searchViewController.vm = SearchViewModel(session)
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
        15
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PlaylistTableViewCell", for: indexPath) as? PlaylistTableViewCell else {
            return UITableViewCell()
        }
        cell.textLabel?.text = "Track Title"
        cell.detailTextLabel?.text = "Artist Name"
        cell.imageView?.image = UIImage(systemName: "photo")
        return cell
    }
}

extension PlaylistViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension PlaylistViewController: SearchViewControllerDelegate {
    func searchViewController(_ searchViewController: SearchViewController, didQueue song: Song) {
        vm.addSong(song) { result in
            if case .failure(let error) = result {
                print(error)
            }
        }
    }
}
