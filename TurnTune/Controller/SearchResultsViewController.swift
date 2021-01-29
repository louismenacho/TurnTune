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
        
    }
}

extension SearchResultsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 25
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchResultsTableViewCell", for: indexPath) as! SearchResultsTableViewCell
        return cell
    }
}

extension SearchResultsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let testSong = Song(id: "", name: "", artistName: "", artworkURL: "", durationInMillis: 0, addedBy: nil)
        roomViewModel.appendSong(testSong, to: roomViewModel.currentUserQueue)
        tableview.deselectRow(at: indexPath, animated: true)
    }
}
