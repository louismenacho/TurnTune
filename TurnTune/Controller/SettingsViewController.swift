//
//  SettingsViewController.swift
//  TurnTune
//
//  Created by Louis Menacho on 4/21/21.
//

import UIKit

class SettingsViewController: UIViewController {
    
    var settingsViewModel = SettingsViewModel()

    @IBOutlet weak var roomIDLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tapGestureRecognizer: UITapGestureRecognizer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        
        settingsViewModel.roomChangeListener { room in
            self.roomIDLabel.text = room.roomID
            self.tableView.reloadData()
        }
        
        settingsViewModel.memberListChangeListener { memberList in
            print("memberListDidChange")
            print(memberList.map { $0.displayName })
            self.tableView.reloadData()
        }
    }
    
    @IBAction func viewTapped(_ sender: UITapGestureRecognizer) {
        dismiss(animated: true, completion: nil)
    }
}

extension SettingsViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let rowCounts = [
            settingsViewModel.queueTypes.count,
            settingsViewModel.memberList.count
        ]
        return rowCounts[section]
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let checkmarkCell = tableView.dequeueReusableCell(withIdentifier: "CheckmarkSettingTableViewCell", for: indexPath) as! CheckmarkSettingTableViewCell
            checkmarkCell.queueType = settingsViewModel.queueTypes[indexPath.row]
            checkmarkCell.isChecked = settingsViewModel.currentQueueType == checkmarkCell.queueType
            return checkmarkCell
        }
        if indexPath.section == 1 {
            let memberCell = tableView.dequeueReusableCell(withIdentifier: "MemberTableViewCell", for: indexPath) as! MemberTableViewCell
            memberCell.member = settingsViewModel.memberList[indexPath.row]
            if settingsViewModel.isHost(memberCell.member) {
                memberCell.hostIndicatorLabel.isHidden = false
                memberCell.isUserInteractionEnabled = false
                memberCell.accessoryType = .none
            }
            return memberCell
        }
        return UITableViewCell()
    }
}

extension SettingsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let sectionTitles = ["Queue Modes", "Members"]
        return sectionTitles[section]
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            let checkmarkCell = tableView.cellForRow(at: indexPath)  as! CheckmarkSettingTableViewCell
            settingsViewModel.updateQueueMode(queueType: checkmarkCell.queueType)
        }
        if indexPath.section == 1 {
            let memberCell = tableView.cellForRow(at: indexPath) as! MemberTableViewCell
            print(memberCell.member.displayName)
            presentAlert(
                title: memberCell.memberDisplayNameLabel.text!,
                alertStyle: .actionSheet,
                actionTitles: ["Remove"],
                actionStyles: [.destructive],
                actions: [
                    { _ in
                        self.settingsViewModel.removeMember(memberCell.member)
                    }
                ],
                completion: { alertController in
                    alertController.view.superview?.subviews[0].addGestureRecognizer(self.tapGestureRecognizer)
                })
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
