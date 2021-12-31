//
//  SessionDetailsViewController.swift
//  TurnTune
//
//  Created by Louis Menacho on 11/19/21.
//

import UIKit

class SessionDetailsViewController: UIViewController {
    
    var vm: SessionDetailsViewModel!

    @IBOutlet weak var sessionIDLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableHeaderView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sessionIDLabel.text = vm.session.id
        tableView.dataSource = self
        tableView.delegate = self
        tableHeaderView.frame.size = CGSize(width: view.frame.width, height: view.frame.width/2)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        vm.membersChangeListener { result in
            switch result {
            case .failure(let error):
                print(error)
            case .success:
                print("members updated")
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        vm.removeMembersChangeListener()
    }
}

extension SessionDetailsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        vm.members.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MemberTableViewCell", for: indexPath) as? MemberTableViewCell else {
            return UITableViewCell()
        }
        cell.member = vm.members[indexPath.row]
        return cell
    }
}

extension SessionDetailsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Members \(vm.members.count)/8"
    }
}
