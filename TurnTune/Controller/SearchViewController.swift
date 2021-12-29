//
//  SearchViewController.swift
//  TurnTune
//
//  Created by Louis Menacho on 11/17/21.
//

import UIKit

protocol SearchViewControllerDelegate: AnyObject {
    func searchViewController(_ searchViewController: SearchViewController, didAdd song: Song)
    func renewSpotifyToken(completion: @escaping (Result<String, Error>) -> Void)
}

class SearchViewController: UIViewController {
    
    weak var delegate: SearchViewControllerDelegate?
    
    var vm: SearchViewModel!
    
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
    }
}

extension SearchViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text else { return }
        vm.updateSearchResult(query: searchText) { [self] result in
            switch result {
            case .failure(let error):
                switch error {
                case .requestFailed(let error):
                    print(error)
                case .decodingError(_):
                    print(error)
                case let .badResponse(code,_,_):
                    if code == 401 {
                        print("2")
                        delegate?.renewSpotifyToken { result in
                            if let newToken = try? result.get() {
                                self.vm.updateSpotifyToken(newToken)
                            }
                        }
                    }
                    print(error)
                case .noResponse:
                    print("No response")
                }
            case .success:
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }
}

extension SearchViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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
        vm.enqueueSong(at: indexPath.row) { result in
            switch result {
            case let .failure(error):
                DispatchQueue.main.async {
                    tableView.deselectRow(at: indexPath, animated: true)
                    tableView.reloadData()
                }
                print(error)
            case let .success(song):
                self.delegate?.searchViewController(self, didAdd: song)
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
}
