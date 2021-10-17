//
//  SettingsViewController.swift
//  TurnTune
//
//  Created by Louis Menacho on 4/21/21.
//

import UIKit

protocol SettingsViewControllerDelegate: AnyObject {
    func settingsViewController(_ settingsViewController: SettingsViewController, didRemoveMember member: Member)
}

class SettingsViewController: UIViewController {
    
    weak var delegate: SettingsViewControllerDelegate?
    
    var settingsViewModel: SettingsViewModel!

    @IBOutlet weak var roomIDLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tapGestureRecognizer: UITapGestureRecognizer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("SettingsViewController willAppear")
        
        settingsViewModel.roomChangeListener { room in
            self.roomIDLabel.text = room.roomID
            self.tableView.reloadData()
        }
        
        settingsViewModel.memberListChangeListener { memberList in
            if memberList == nil {
                DispatchQueue.main.async {
                    self.navigationController?.popToRootViewController(animated: true)
                }
            } else {
                self.tableView.reloadData()
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        print("SettingsViewController viewWillDisappear")
        settingsViewModel.removeAllListeners()
    }
    
    @IBAction func viewTapped(_ sender: UITapGestureRecognizer) {
        dismiss(animated: true, completion: nil)
    }
}

extension SettingsViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settingsViewModel.memberList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let memberCell = tableView.dequeueReusableCell(withIdentifier: "MemberTableViewCell", for: indexPath) as! MemberTableViewCell
        memberCell.isCurrentMemberHost = settingsViewModel.isCurrentMemberHost
        memberCell.member = settingsViewModel.memberList[indexPath.row]
        return memberCell
    }
}

extension SettingsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Members"
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let memberCell = tableView.cellForRow(at: indexPath) as! MemberTableViewCell
        presentAlert(
            title: memberCell.memberDisplayNameLabel.text!,
            alertStyle: .actionSheet,
            actionTitles: ["Remove"],
            actionStyles: [.destructive],
            actions: [
                { _ in
                    self.settingsViewModel.removeMember(memberCell.member) {
                        self.delegate?.settingsViewController(self, didRemoveMember: memberCell.member)
                    }
                }
            ],
            completion: { alertController in
                alertController.view.superview?.subviews[0].addGestureRecognizer(self.tapGestureRecognizer)
            })
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
