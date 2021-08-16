//
//  PlayerViewController.swift
//  TurnTune
//
//  Created by Louis Menacho on 7/22/21.
//

import UIKit

class PlayerViewController: UIViewController {
    
    var playerViewModel = PlayerViewModel(musicPlayerService: SpotifyMusicPlayerService())
    
//    var playbackView: PlaybackView?
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var playbackView: PlaybackView!
    @IBOutlet weak var miniPlaybackView: PlaybackView!
    @IBOutlet weak var miniPaybackViewBottomConstraint: NSLayoutConstraint!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationController!.navigationBar.standardAppearance.shadowColor = .clear
        navigationItem.hidesSearchBarWhenScrolling = false
        navigationItem.searchController = prepareSearchViewController()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        
        miniPaybackViewBottomConstraint.constant = -114
            
        playerViewModel.playerStateChangeListener { playerState in
            print("playerStateDidChange")
            self.playbackView.playerState = playerState
            self.miniPlaybackView.playerState = playerState
        }
        
        playerViewModel.queueChangeListener { queue in
            print("queueDidChange")
            self.tableView.reloadSections([0], with: .automatic)
        }
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
    }
    
    @IBAction func playNextSongButton(_ sender: Any) {
        playerViewModel.playNextSong()
    }
    
    @IBAction func playerDetailsButtonPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "PlayerDetailViewController", sender: self)
    }
    
    @IBAction func settingsButtonPressed(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "SettingsTableViewController", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PlayerDetailViewController" {
            let playerDetailViewController = segue.destination as! PlayerDetailViewController
            playerDetailViewController.playerState = playbackView.playerState
        }
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
extension PlayerViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return playerViewModel.queue.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SongTableViewCell", for: indexPath) as! SongTableViewCell
        cell.song = playerViewModel.queue[indexPath.row]
        return cell
    }
}


// MARK: - UITableViewDelegate
extension PlayerViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "QUEUE"
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let sectionHeaderView = view as? UITableViewHeaderFooterView else { return }
        sectionHeaderView.textLabel?.font = UIFont.systemFont(ofSize: 12)
        sectionHeaderView.textLabel?.textColor = .label
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.frame.width * (82/tableView.frame.width)
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 114
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y <= 114 {
            UIView.animate(withDuration: 0.3) { [self] in
                miniPaybackViewBottomConstraint.constant = -114
                view.layoutIfNeeded()
            }
        }
        if scrollView.contentOffset.y > 114 {
            UIView.animate(withDuration: 0.3) { [self] in
                miniPaybackViewBottomConstraint.constant = 0
                view.layoutIfNeeded()
            }
        }
    }
}


// MARK: - UITableViewDelegate
extension PlayerViewController: PlaybackViewDelegate {
    func playbackView(playButtonPressedFor playbackView: PlaybackView) {
        playerViewModel.play()
    }
    
    func playbackView(pauseButtonPressedFor playbackView: PlaybackView) {
        playerViewModel.pause()
    }
}
