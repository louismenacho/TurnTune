//
//  PlayerViewController.swift
//  TurnTune
//
//  Created by Louis Menacho on 7/22/21.
//

import UIKit

class PlayerViewController: UITableViewController {
    
    var playerViewModel = PlayerViewModel(musicPlayerService: SpotifyMusicPlayerService())

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationController!.navigationBar.standardAppearance.shadowColor = .clear
        navigationItem.hidesSearchBarWhenScrolling = false
        navigationItem.searchController = prepareSearchViewController()
        
        playerViewModel.playerStateChangeListener { playerState in
            print("playerStateDidChange")
            self.tableView.reloadSections([0], with: .automatic)
        }
        
        playerViewModel.queueChangeListener { queue in
            print("queueDidChange")
            self.tableView.reloadSections([1], with: .automatic)
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationItem.hidesSearchBarWhenScrolling = true
    }
    
    private func prepareSearchViewController() -> UISearchController {
        let searchViewController = prepareSearchResultsViewController()
        let searchController = UISearchController(searchResultsController: searchViewController)
        searchController.searchResultsUpdater = searchViewController
        searchController.delegate = self
        searchController.searchBar.autocapitalizationType = .none
        searchController.searchBar.placeholder = "Search songs"
        return searchController
    }

    private func prepareSearchResultsViewController() -> SearchViewController {
        guard let searchResultsViewController = storyboard?.instantiateViewController(identifier: "SearchViewController") as? SearchViewController else {
            fatalError("Could not instantiate SearchViewController")
        }
        searchResultsViewController.delegate = self
        return searchResultsViewController
    }
    
    @IBAction func playButtonPressed(_ sender: Any) {
        playerViewModel.resumeQueue()
    }
    
    @IBAction func settingsButtonPressed(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "SettingsTableViewController", sender: self)
    }
}


// MARK: - UISearchControllerDelegate
extension PlayerViewController: UISearchControllerDelegate {
    func presentSearchController(_ searchController: UISearchController) {
        searchController.showsSearchResultsController = true
    }
}


// MARK: - SearchViewControllerDelegate
extension PlayerViewController: SearchViewControllerDelegate {
    func searchViewController(searchViewController: SearchViewController, didSelectCell cell: SearchResultsTableViewCell) {
        playerViewModel.addToQueue(cell.song)
    }
}


// MARK: - UITableViewDataSource
extension PlayerViewController {

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionCount = [1, playerViewModel.queue.count]
        return sectionCount[section]
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {

        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "PlayerStateTableViewCell", for: indexPath) as! PlayerStateTableViewCell
            cell.playerState = playerViewModel.playerState
            return cell

        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SongTableViewCell", for: indexPath) as! SongTableViewCell
            cell.song = playerViewModel.queue[indexPath.row]
            return cell

        default:
            return UITableViewCell()
        }
    }
}

// MARK: - UITableViewDelegate
extension PlayerViewController {

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let titles = ["NOW PLAYING", "YOUR QUEUE"]
        return titles[section]
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return tableView.frame.width * (124.5/tableView.frame.width)
        }
        else {
            return tableView.frame.width * (82/tableView.frame.width)
        }
    }
}
