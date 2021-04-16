//
//  RoomViewController.swift
//  TurnTune
//
//  Created by Louis Menacho on 12/23/20.
//

import UIKit

class RoomViewController: UIViewController {
    
    var roomViewModel: RoomViewModel!
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController!.navigationBar.standardAppearance.shadowColor = .clear
        navigationItem.hidesBackButton = true
//        navigationItem.hidesSearchBarWhenScrolling = false
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
    
    @IBAction func reconnectButtonPressed(_ sender: UIBarButtonItem) {
        SpotifyAppRemote.shared.connectIfNeeded()
    }
}



// MARK: - RoomViewModelDelegate
extension RoomViewController: RoomViewModelDelegate {
        
    func roomViewModel(roomViewModel: RoomViewModel, didInitialize: Bool) {
        navigationItem.title = roomViewModel.room.code
        tableView.dataSource = self
        tableView.delegate = self
        tableView.reloadData()
    }
    
    func roomViewModel(roomViewModel: RoomViewModel, didUpdate room: Room) {
        tableView.reloadSections(IndexSet(integersIn: 0...0), with: .automatic)
    }
    
    func roomViewModel(roomViewModel: RoomViewModel, didUpdate members: [Member]) {
        
    }
    
    func roomViewModel(roomViewModel: RoomViewModel, didUpdate queue: [Song]) {
        print("Queue Count: \(queue.count)")
        tableView.reloadData()
    }
}



// MARK: - UISearchControllerDelegate
extension RoomViewController: UISearchControllerDelegate {
    func presentSearchController(_ searchController: UISearchController) {
        searchController.showsSearchResultsController = true
    }
}



// MARK: - UITableViewDataSource
extension RoomViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionCount = [1, 1, roomViewModel.queue.count]
        return sectionCount[section]
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CurrentSongTableViewCell", for: indexPath) as! CurrentSongTableViewCell
            if let song = roomViewModel.room.playingSong {
                cell.song = song
            } else {
                cell.songLabel.text = "No song playing"
                cell.artistLabel.text = ""
            }
            return cell
        }
        
        if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddSongButtonTableViewCell", for: indexPath)
            return cell
        }
        
        else {
            let song = roomViewModel.queue[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "SongTableViewCell", for: indexPath) as! SongTableViewCell
            cell.song = song
            return cell
        }
    }
}



// MARK: - UITableViewDelegate
extension RoomViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 2 {
            let selectedCell = tableView.cellForRow(at: indexPath) as! SongTableViewCell
            roomViewModel.play(selectedCell.song!)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return tableView.frame.width * (124.5/414)
        }
        if indexPath.section == 1 {
            return tableView.frame.width * (30/414)
        } else {
            return 82
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Now Playing"
        }
        if section == 1 {
            return nil
        }
        if section == 2 {
            return "Room Queue"
        }
        return nil
    }
}

//AddSongButtonTableViewCell
