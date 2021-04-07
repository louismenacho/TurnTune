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
        navigationItem.title = roomViewModel.room.code
    }
    
    func roomViewModel(roomViewModel: RoomViewModel, didUpdate room: Room) {
        
    }
    
    func roomViewModel(roomViewModel: RoomViewModel, didUpdate members: [Member]) {
        
    }
    
    func roomViewModel(roomViewModel: RoomViewModel, didUpdate queue: [Song]) {
        print("Queue Count: \(queue.count)")
    }
}



// MARK: - UISearchControllerDelegate
extension RoomViewController: UISearchControllerDelegate {
    func presentSearchController(_ searchController: UISearchController) {
        searchController.showsSearchResultsController = true
    }
}
