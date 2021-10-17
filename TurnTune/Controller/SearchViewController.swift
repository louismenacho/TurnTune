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
    func searchViewController(_ searchViewController: SearchViewController, addSongForCell cell: SearchResultsTableViewCell) -> Int
}

class SearchViewController: UIViewController {
    
    weak var delegate: SearchViewControllerDelegate?
    
    var searchViewModel: SearchViewModel!
    
    var timer: Timer?
    
    lazy var actvityIndicator = NVActivityIndicatorView(
        frame: view.bounds,
        padding: view.frame.width/2 - 30
    )
    
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var songCountLabel: UILabel!
    @IBOutlet weak var songCountViewBottomConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableview.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: tableview.frame.width, height: 1))
        tableview.dataSource = self
        
        songCountViewBottomConstraint.constant = -76
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
        guard
            delegate?.searchViewController(self, shouldAddSongForCell: cell) == true,
            let newSongCount = delegate?.searchViewController(self, addSongForCell: cell),
            let selectedRow = tableview.indexPath(for: cell)?.row
        else {
            songCountLabel.text = "Cannot add anymore songs"
            UIView.animate(withDuration: 0.3) { [self] in
                songCountViewBottomConstraint.constant = 0
                view.layoutIfNeeded()
            }
            
            timer?.invalidate()
            timer = Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { timer in
                
                UIView.animate(withDuration: 0.3) { [self] in
                    songCountViewBottomConstraint.constant = -76
                    view.layoutIfNeeded()
                }
            }
            return
        }
            
        songCountLabel.text = "\(newSongCount) / 10 songs added"
        UIView.animate(withDuration: 0.3) { [self] in
            songCountViewBottomConstraint.constant = 0
            view.layoutIfNeeded()
        }
        
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { timer in
            
            UIView.animate(withDuration: 0.3) { [self] in
                songCountViewBottomConstraint.constant = -76
                view.layoutIfNeeded()
            }
        }
        
        searchViewModel.searchResult[selectedRow].isAdded = true
        tableview.reloadData()
    }
}
