//
//  PlayerViewController.swift
//  TurnTune
//
//  Created by Louis Menacho on 7/22/21.
//

import UIKit


class PlayerViewController: UIViewController {
    
    var searchViewModel: SearchViewModel!
    var settingsViewModel: SettingsViewModel!
    var playerViewModel: PlayerViewModel!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var playbackView: PlaybackView!
    @IBOutlet weak var miniPlaybackView: PlaybackView!
    @IBOutlet weak var miniPlaybackViewBottomConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController!.navigationBar.prefersLargeTitles = false
        navigationController!.navigationBar.standardAppearance.shadowColor = .clear
        navigationItem.hidesSearchBarWhenScrolling = false
        navigationItem.searchController = prepareSearchController()
        
        playbackView.frame.size = CGSize(width: playbackView.frame.width, height: view.frame.width/3+40)
        miniPlaybackViewBottomConstraint.constant = -114
        
        tableView.dataSource = self
        tableView.delegate = self
        playbackView.delegate = self
        miniPlaybackView.delegate = self
        
        if playerViewModel.musicPlayerService == nil {
            hidePlayerControls()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("PlayerViewController willAppear")
        
        settingsViewModel.roomChangeListener { room in
            self.navigationItem.title = room.roomID
        }
        
        settingsViewModel.memberListChangeListener { memberList in
            if memberList == nil {
                DispatchQueue.main.async {
                    self.navigationController?.popToRootViewController(animated: true)
                }
            }
        }
        
        playerViewModel.playerStateChangeListener { playerState in
            print("updating playback views")
            self.playbackView.playerState = playerState
            self.miniPlaybackView.playerState = playerState
        }
        
        playerViewModel.queueChangeListener { queue in
            print("queueDidChange")
            self.tableView.reloadSections([0], with: .automatic)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        print("PlayerViewController viewWillDisappear")
        settingsViewModel.removeAllListeners()
        playerViewModel.removeAllListeners()
    }
    
    private func prepareSearchController() -> UISearchController {
        let searchViewController = prepareSearchViewController()
        let searchController = UISearchController(searchResultsController: searchViewController)
        searchController.searchResultsUpdater = searchViewController
        searchController.delegate = self
        searchController.searchBar.autocapitalizationType = .none
        searchController.searchBar.placeholder = "Search songs"
        return searchController
    }

    private func prepareSearchViewController() -> SearchViewController {
        guard let searchResultsViewController = storyboard?.instantiateViewController(identifier: "SearchViewController") as? SearchViewController else {
            fatalError("Could not instantiate SearchViewController")
        }
        searchResultsViewController.delegate = self
        searchResultsViewController.searchViewModel = searchViewModel
        return searchResultsViewController
    }
    
    private func hidePlayerControls() {
        playbackView.rewindButton.isHidden = true
        playbackView.playPauseButton.isHidden = true
        playbackView.playNextButton.isHidden = true
        miniPlaybackView.playPauseButton.isHidden = true
    }
    
    @IBAction func settingsButtonPressed(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "SettingsViewController", sender: self)
    }
    
    @IBAction func albumImageTapped(_ sender: UITapGestureRecognizer) {
        performSegue(withIdentifier: "PlayerDetailViewController", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PlayerDetailViewController" {
            let playerDetailViewController = segue.destination as! PlayerDetailViewController
            playerDetailViewController.playerViewModel = playerViewModel
            playerDetailViewController.settingsViewModel = settingsViewModel
        }
        if segue.identifier == "SettingsViewController" {
            let settingsViewController = segue.destination as! SettingsViewController
            settingsViewController.settingsViewModel = settingsViewModel
            settingsViewController.delegate = self
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
        if let currentMember = settingsViewModel.currentMember, let currentMemberPosition = settingsViewModel.currentMemberPosition {
            playerViewModel.addToQueue(cell.searchResultItem.song, addedBy: currentMember, memberPosition: currentMemberPosition)
        }
    }
}


// MARK: - PlaybackViewDelegate
extension PlayerViewController: PlaybackViewDelegate {
    
    func playbackView(rewindButtonPressedFor playbackView: PlaybackView) {
        playerViewModel.rewindSong()
    }
    
    func playbackView(playPauseButtonPressedFor playbackView: PlaybackView) {
        playerViewModel.playerState.isPaused ? playerViewModel.play() : playerViewModel.pause()
    }

    func playbackView(playNextButtonPressedFor playbackView: PlaybackView) {
        playerViewModel.playNextSong()
    }
    
    func playbackView(startQueueButtonPressedFor playbackView: PlaybackView) {
        playerViewModel.startQueue() {
            
        }
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
        cell.queueItem = playerViewModel.queue[indexPath.row]
        return cell
    }
}


// MARK: - UITableViewDelegate
extension PlayerViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "QUEUE"
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
                miniPlaybackViewBottomConstraint.constant = -114
                view.layoutIfNeeded()
            }
        }
        if scrollView.contentOffset.y > 114 {
            UIView.animate(withDuration: 0.3) { [self] in
                miniPlaybackViewBottomConstraint.constant = 0
                view.layoutIfNeeded()
            }
        }
    }
}


// MARK: - SettingsViewControllerDelegate
extension PlayerViewController: SettingsViewControllerDelegate {
    
    func settingsViewController(_ settingsViewController: SettingsViewController, didRemoveMember member: Member) {
        playerViewModel.removeQueueItems(for: member)
    }
}
