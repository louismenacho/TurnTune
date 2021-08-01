//
//  PlayerViewController.swift
//  TurnTune
//
//  Created by Louis Menacho on 7/22/21.
//

import UIKit

class PlayerViewController: UITableViewController {
    
    var playerViewModel = PlayerViewModel(musicPlayerService: SpotifyMusicPlayerService())
    
    @IBOutlet weak var playerStateView: PlayerStateView!
    private var savedPlayerStateView: PlayerStateView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationController!.navigationBar.standardAppearance.shadowColor = .clear
        navigationItem.hidesSearchBarWhenScrolling = false
        navigationItem.searchController = prepareSearchViewController()
        
        playerViewModel.playerStateChangeListener { playerState in
            print("playerStateDidChange")
            self.playerStateView.playerState = playerState
        }
        
        playerViewModel.queueChangeListener { queue in
            print("queueDidChange")
            self.tableView.reloadSections([0], with: .automatic)
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
        playerViewModel.play()
//        if tableView.tableHeaderView == nil {
//            playerStateView = savedPlayerStateView
//            tableView.tableHeaderView = playerStateView
//        } else {
//            savedPlayerStateView = playerStateView
//            tableView.tableHeaderView = nil
//        }
    }
    
    @IBAction func playNextSongButton(_ sender: Any) {
        playerViewModel.playNextSong()
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
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return playerViewModel.queue.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SongTableViewCell", for: indexPath) as! SongTableViewCell
        cell.song = playerViewModel.queue[indexPath.row]
        return cell
    }
}


// MARK: - UITableViewDelegate
extension PlayerViewController {

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "QUEUE"
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let sectionHeaderView = view as? UITableViewHeaderFooterView else { return }
        sectionHeaderView.textLabel?.font = UIFont.systemFont(ofSize: 12)
        sectionHeaderView.textLabel?.textColor = .label
        print(sectionHeaderView.frame)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.frame.width * (82/tableView.frame.width)
    }
}
