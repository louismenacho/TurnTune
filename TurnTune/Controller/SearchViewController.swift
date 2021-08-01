//
//  SearchViewController.swift
//  TurnTune
//
//  Created by Louis Menacho on 12/29/20.
//

import UIKit

protocol SearchViewControllerDelegate: AnyObject {
    func searchViewController(searchViewController: SearchViewController, didSelectCell cell: SearchResultsTableViewCell)
}

class SearchViewController: UIViewController {
    
    weak var delegate: SearchViewControllerDelegate?

    var searcherViewModel = SearcherViewModel(musicBrowserService: SpotifyMusicBrowser())
    
    @IBOutlet weak var tableview: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableview.dataSource = self
    }
}

extension SearchViewController: UISearchResultsUpdating {
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

extension SearchViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searcherViewModel.searchResult.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row >= searcherViewModel.searchResult.count {
            return UITableViewCell()
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchResultsTableViewCell", for: indexPath) as! SearchResultsTableViewCell
        cell.delegate = self
        
        cell.song = searcherViewModel.searchResult[indexPath.row]
        return cell
    }
}

extension SearchViewController: SearchResultsTableViewCellDelegate {
    func searchResultsTableViewCell(addButtonPressedFor cell: SearchResultsTableViewCell) {
        delegate?.searchViewController(searchViewController: self, didSelectCell: cell)
    }
}
