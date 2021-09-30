//
//  SettingsViewController.swift
//  TurnTune
//
//  Created by Louis Menacho on 4/21/21.
//

import UIKit

class SettingsViewController: UIViewController {
    
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
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let rowCounts = [
            1,
            settingsViewModel.memberList.count
        ]
        return rowCounts[section]
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let queueModeCell = tableView.dequeueReusableCell(withIdentifier: "QueueModeTableViewCell", for: indexPath) as! QueueModeTableViewCell
            queueModeCell.queueType = settingsViewModel.currentQueueType
            queueModeCell.isCurrentMemberHost = settingsViewModel.isCurrentMemberHost
            return queueModeCell
        }
        if indexPath.section == 1 {
            let memberCell = tableView.dequeueReusableCell(withIdentifier: "MemberTableViewCell", for: indexPath) as! MemberTableViewCell
            memberCell.isCurrentMemberHost = settingsViewModel.isCurrentMemberHost
            memberCell.member = settingsViewModel.memberList[indexPath.row]
            return memberCell
        }
        return UITableViewCell()
    }
}

extension SettingsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let sectionTitles = ["Queue", "Members"]
        return sectionTitles[section]
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            let queueModeCell = tableView.cellForRow(at: indexPath)  as! QueueModeTableViewCell
            presentAlert(
                title: queueModeCell.queueModeLabel.text!,
                alertStyle: .actionSheet,
                actionTitles: settingsViewModel.queueTypes.map { $0.rawValue.capitalized },
                actionStyles: settingsViewModel.queueTypes.map { _ in UIAlertAction.Style.default },
                actions: settingsViewModel.queueTypes.map { queueType in
                    { _ in
                        self.settingsViewModel.updateQueueMode(queueType: queueType)
                    }
                },
                completion: { alertController in
                    alertController.view.superview?.subviews[0].addGestureRecognizer(self.tapGestureRecognizer)
                })
        }
        if indexPath.section == 1 {
            let memberCell = tableView.cellForRow(at: indexPath) as! MemberTableViewCell
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
