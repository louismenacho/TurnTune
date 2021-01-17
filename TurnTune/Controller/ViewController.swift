//
//  ViewController.swift
//  TurnTune
//
//  Created by Louis Menacho on 12/23/20.
//

import UIKit

class ViewController: UIViewController {

    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController!.navigationBar.standardAppearance.shadowColor = .clear
        
        navigationItem.searchController = prepareSearchController()
        navigationItem.hidesSearchBarWhenScrolling = false
        navigationItem.hidesBackButton = true
        
        collectionView.dataSource = self
        tableView.dataSource = self
        tableView.delegate = self
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
        searchController.searchBar.placeholder = "Search songs"
        searchController.searchBar.autocapitalizationType = .none
        return searchController
    }
    
    private func prepareSearchResultsViewController() -> SearchResultsViewController {
        guard let searchResultsViewController = storyboard?.instantiateViewController(identifier: "SearchResultsViewController") as? SearchResultsViewController else {
            fatalError("Could not instantiate SearchResultsViewController")
        }
        return searchResultsViewController
    }
}

// MARK: - SearchController

extension ViewController: UISearchControllerDelegate {
    func presentSearchController(_ searchController: UISearchController) {
        searchController.showsSearchResultsController = true
    }
}

// MARK: - TableView

extension ViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let rowCount = [1,9]
        return rowCount[section]
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cells = [UITableViewCell]()
        cells.append(tableView.dequeueReusableCell(withIdentifier: "SongTableViewCell", for: indexPath) as! SongTableViewCell)
        cells.append(tableView.dequeueReusableCell(withIdentifier: "SongTableViewCell", for: indexPath) as! SongTableViewCell)
        return cells[indexPath.section]
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let titles = ["NOW PLAYING", "UP NEXT"]
        return titles[section]
    }
}

// MARK: - SongTableViewCell

class SongTableViewCell: UITableViewCell {
    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var addedByLabel: UILabel!
    @IBOutlet weak var songLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    
    override func awakeFromNib() {
        userImageView.image = UIImage(systemName: "person.crop.circle")
        addedByLabel.text = "Added by Louis"
        songLabel.text = "Beat it"
        artistLabel.text = "Michael Jackson"
    }
}

// MARK: - CollectionView

extension ViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewCell", for: indexPath) as! CollectionViewCell
        return cell
    }
}

class CollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var userImageView: UIImageView!
    
    override func awakeFromNib() {
        userImageView.image = UIImage(systemName: "person.crop.circle")
    }
}
