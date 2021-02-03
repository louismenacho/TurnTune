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
    @IBOutlet weak var tableView: UITableView!
    
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
}



// MARK: - RoomViewModelDelegate
extension RoomViewController: RoomViewModelDelegate {
    
    func roomViewModel(roomViewModel: RoomViewModel, didInitialize: Bool) {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.reloadData()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.reloadData()
    }
    
    func roomViewModel(roomViewModel: RoomViewModel, didUpdate room: Room) {
        self.tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
    }
    
    func roomViewModel(roomViewModel: RoomViewModel, didUpdate members: [Member]) {
        collectionView.reloadData()
    }
    
    func roomViewModel(roomViewModel: RoomViewModel, didUpdate queues: [Queue]) {
        self.tableView.reloadSections(IndexSet(integer: 1), with: .automatic)
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



// MARK: - UITableViewDataSource
extension RoomViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var rowCount: Int
        switch section {
        case 0:
            rowCount = 1
        default:
            rowCount = roomViewModel.currentUserQueue.songs.count
        }
        return rowCount
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SongTableViewCell") as! SongTableViewCell
        switch indexPath.section {
        case 0:
            cell.nameLabel.text = roomViewModel.playingSong?.name ?? ""
            cell.artistNameLabel.text = roomViewModel.playingSong?.artistName ?? ""
        default:
            cell.nameLabel.text = roomViewModel.currentUserQueue.songs[indexPath.row].name
            cell.artistNameLabel.text = roomViewModel.currentUserQueue.songs[indexPath.row].artistName
        }
        return cell
    }
}



// MARK: - UITableViewDelegate
extension RoomViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let titles = ["NOW PLAYING", "YOUR QUEUE"]
        return titles[section]
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            roomViewModel.deleteSong(from: roomViewModel.currentUserQueue, at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
}






//// MARK: - UICollectionViewDataSource
//extension RoomViewController: UICollectionViewDataSource {
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return 10
//    }
//
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MemberCollectionViewCell", for: indexPath) as! MemberCollectionViewCell
//        return cell
//    }
//}
//
//
//
//// MARK: - UICollectionViewDelegate
//extension RoomViewController: UICollectionViewDelegate {
//
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        print("\(indexPath) item selected")
//        collectionView.deselectItem(at: indexPath, animated: true)
//    }
//}
//
//
//
//// MARK: - UITableViewDataSource
//extension RoomViewController: UITableViewDataSource {
//
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return 2
//    }
//
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        let rowCount = [1,9]
//        return rowCount[section]
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        var cells = [UITableViewCell]()
//        cells.append(tableView.dequeueReusableCell(withIdentifier: "SongTableViewCell", for: indexPath) as! SongTableViewCell)
//        cells.append(tableView.dequeueReusableCell(withIdentifier: "SongTableViewCell", for: indexPath) as! SongTableViewCell)
//        return cells[indexPath.section]
//    }
//}
//
//
//
//// MARK: - UITableViewDelegate
//extension RoomViewController: UITableViewDelegate {
//
//    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        let titles = ["NOW PLAYING", "UP NEXT"]
//        return titles[section]
//    }
//
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        print("\(indexPath) row selected")
//        tableView.deselectRow(at: indexPath, animated: true)
//    }
//}
