//
//  RoomViewController.swift
//  TurnTune
//
//  Created by Louis Menacho on 12/23/20.
//

import UIKit

class RoomViewController: UITableViewController {
    
    var roomManager: RoomManagerService?
    var newRoomViewModel: NewRoomViewModel?
    var roomViewModel: RoomViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController!.navigationBar.standardAppearance.shadowColor = .clear
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
//        navigationItem.hidesBackButton = true
//        navigationItem.hidesSearchBarWhenScrolling = false
        navigationItem.searchController = prepareSearchViewController()
        
        roomViewModel.delegate = self
        

        //The controller constructs the view model using data obtained from an application service or directly from a repository. The view model can contain a constructor which accepts an entity returned by the service or repository.
    }
    
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//        navigationItem.hidesSearchBarWhenScrolling = true
//    }
    
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
        searchResultsViewController.searcherViewModel = SearcherViewModel()
        searchResultsViewController.roomViewModel = roomViewModel
        return searchResultsViewController
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SettingsTableViewController" {
            let settingsTableViewController = segue.destination as! SettingsTableViewController
            settingsTableViewController.roomViewModel = roomViewModel
        }
    }
    
    @IBAction func settingsButtonPressed(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "SettingsTableViewController", sender: self)
    }
}



// MARK: - RoomViewModelDelegate
extension RoomViewController: RoomViewModelDelegate {
        
    func roomViewModel(roomViewModel: RoomViewModel, didInitialize: Bool) {
        navigationItem.title = roomViewModel.room?.id
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
extension RoomViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionCount = [1, roomViewModel.queue.count]
        return sectionCount[section]
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CurrentSongTableViewCell", for: indexPath) as! CurrentSongTableViewCell
            if let song = roomViewModel.room?.playingSong {
                cell.song = song
            } else {
                cell.songLabel.text = "No song playing"
                cell.artistLabel.text = ""
            }
            return cell
        }
        else if !roomViewModel.queue.isEmpty {
            let song = roomViewModel.queue[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "SongTableViewCell", for: indexPath) as! SongTableViewCell
            cell.song = song
            return cell
        } else {
            return UITableViewCell()
        }
    }
}



// MARK: - UITableViewDelegate
extension RoomViewController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            let selectedCell = tableView.cellForRow(at: indexPath) as! SongTableViewCell
            roomViewModel.play(selectedCell.song!)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return tableView.frame.width * (124.5/tableView.frame.width)
        }
        else {
            return tableView.frame.width * (82/tableView.frame.width)
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Now Playing"
        }
        if section == 1 {
            return "Room Queue"
        }
        return nil
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
}
