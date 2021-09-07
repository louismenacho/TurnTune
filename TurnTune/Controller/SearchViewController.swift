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

    var searchViewModel: SearchViewModel!
    
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
        searchViewModel.search(query: searchController.searchBar.searchTextField.text!) {
            DispatchQueue.main.async {
                self.tableview.reloadData()
            }
        }
    }
}

extension SearchViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchViewModel.searchResult.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row >= searchViewModel.searchResult.count {
            return UITableViewCell()
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchResultsTableViewCell", for: indexPath) as! SearchResultsTableViewCell
        cell.delegate = self
        
        cell.searchResultItem = searchViewModel.searchResult[indexPath.row]
        return cell
    }
}

extension SearchViewController: SearchResultsTableViewCellDelegate {
    func searchResultsTableViewCell(addButtonPressedFor cell: SearchResultsTableViewCell) {
        guard let selectedRow = tableview.indexPath(for: cell)?.row else {
            return
        }
        searchViewModel.searchResult[selectedRow].isAdded = true
        tableview.reloadData()
        delegate?.searchViewController(searchViewController: self, didSelectCell: cell)
    }
}
