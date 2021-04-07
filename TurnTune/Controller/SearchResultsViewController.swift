//
//  SearchResultsViewController.swift
//  TurnTune
//
//  Created by Louis Menacho on 12/29/20.
//

import UIKit
import Firebase
import FirebaseFirestoreSwift

class SearchResultsViewController: UIViewController {

    var searcherViewModel: SearcherViewModel!
    var roomViewModel: RoomViewModel!
    
    @IBOutlet weak var tableview: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableview.dataSource = self
        tableview.delegate = self
    }
}

extension SearchResultsViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        if searchController.searchBar.searchTextField.text!.isEmpty {
            return
        }
        searcherViewModel.search(query: searchController.searchBar.searchTextField.text!) {
            DispatchQueue.main.async {
                self.tableview.reloadData()
            }
        }
    }
}

extension SearchResultsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searcherViewModel.searchResult.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row >= searcherViewModel.searchResult.count {
            return UITableViewCell()
        }
        let song = searcherViewModel.searchResult[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchResultsTableViewCell", for: indexPath) as! SearchResultsTableViewCell
        cell.song = song
        return cell
    }
}

extension SearchResultsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedCell = tableview.cellForRow(at: indexPath) as! SearchResultsTableViewCell
        roomViewModel.queueSong(selectedCell.song!)
        tableview.deselectRow(at: indexPath, animated: true)
    }
}
