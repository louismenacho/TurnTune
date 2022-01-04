//
//  SearchViewController.swift
//  TurnTune
//
//  Created by Louis Menacho on 11/17/21.
//

import UIKit

protocol SearchViewControllerDelegate: AnyObject {
    func searchViewController(_ searchViewController: SearchViewController, didAdd song: Song)
    func searchViewController(_ searchViewController: SearchViewController, renewSpotifyToken: Void)
}

class SearchViewController: UIViewController {
    
    weak var delegate: SearchViewControllerDelegate?
    
    var vm: SearchViewModel!
    
    @IBOutlet weak var tableViewHeaderLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
    }
}

extension SearchViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text, !searchText.isEmpty else { return }
        vm.updateSearchResult(query: searchText) { [self] result in
            switch result {
            case .success:
                DispatchQueue.main.async {
                    tableView.reloadData()
                }
            case .failure(let error):
                switch error {
                case .requestFailed:
                    print(error)
                case .decodingError:
                    print(error)
                case .noResponse:
                    print(error)
                case .badResponse(let code, _, _):
                    print(error)
                    if code == 401 {
                        print("renewSpotifyToken")
                        delegate?.searchViewController(self, renewSpotifyToken: ())
                    }
                }
            }
        }
    }
}

extension SearchViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableViewHeaderLabel.isHidden = vm.searchResult.count == 0
        return vm.searchResult.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row >= vm.searchResult.count {
            return UITableViewCell()
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchTableViewCell", for: indexPath) as! SearchTableViewCell
        cell.searchResultItem = vm.searchResult[indexPath.row]
        return cell
    }
}

extension SearchViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        vm.enqueueSong(at: indexPath.row) { [self] result in
            switch result {
            case let .success(song):
                self.delegate?.searchViewController(self, didAdd: song)
            case let .failure(error):
                switch error {
                case .requestFailed:
                    print(error)
                case .decodingError:
                    print(error)
                case .noResponse:
                    print(error)
                case .badResponse(let code, _, _):
                    print(error)
                    if code == 401 {
                        delegate?.searchViewController(self, renewSpotifyToken: ())
                    }
                }
                DispatchQueue.main.async {
                    tableView.deselectRow(at: indexPath, animated: true)
                    tableView.reloadData()
                }
            }
        }
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return vm.searchResult[indexPath.row].isAdded ? nil : indexPath
    }
        
    func tableView(_ tableView: UITableView, willDeselectRowAt indexPath: IndexPath) -> IndexPath? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 68
    }
}
