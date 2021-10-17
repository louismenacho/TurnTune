//
//  SearchViewController.swift
//  TurnTune
//
//  Created by Louis Menacho on 12/29/20.
//

import UIKit
import NVActivityIndicatorView
import NVActivityIndicatorViewExtended

protocol SearchViewControllerDelegate: AnyObject {
    func searchViewController(_ searchViewController: SearchViewController, shouldAddSongForCell cell: SearchResultsTableViewCell) -> Bool
    func searchViewController(_ searchViewController: SearchViewController, addSongForCell cell: SearchResultsTableViewCell)
}

class SearchViewController: UIViewController {
    
    weak var delegate: SearchViewControllerDelegate?

    var searchViewModel: SearchViewModel!
    
    lazy var actvityIndicator = NVActivityIndicatorView(
        frame: view.bounds,
        padding: view.frame.width/2 - 30
    )
    
    @IBOutlet weak var tableview: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableview.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: tableview.frame.width, height: 1))
        tableview.dataSource = self
    }
    
    func startActivityIndicator() {
        DispatchQueue.main.async { [self] in
            view.addSubview(actvityIndicator)
            actvityIndicator.backgroundColor = .black
            actvityIndicator.alpha = 0.5
            actvityIndicator.startAnimating()
        }
    }
    
    func stopActivityIndicator() {
        DispatchQueue.main.async { [self] in
            actvityIndicator.stopAnimating()
            actvityIndicator.removeFromSuperview()
        }
    }
}


extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        startActivityIndicator()
        searchViewModel.search(query: searchBar.searchTextField.text!) { [self] in
            DispatchQueue.main.async {
                tableview.reloadData()
                stopActivityIndicator()
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
        if delegate?.searchViewController(self, shouldAddSongForCell: cell) == true {
            delegate?.searchViewController(self, addSongForCell: cell)
            searchViewModel.searchResult[selectedRow].isAdded = true
            tableview.reloadData()
        }
    }
}
