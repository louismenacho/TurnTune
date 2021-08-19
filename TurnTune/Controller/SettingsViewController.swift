//
//  SettingsViewController.swift
//  TurnTune
//
//  Created by Louis Menacho on 4/21/21.
//

import UIKit

class SettingsViewController: UIViewController {
    
    var settingsViewModel = SettingsViewModel()
    lazy var alertController = AlertController(for: self)

    @IBOutlet weak var roomIDLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tapGestureRecognizer: UITapGestureRecognizer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Room Settings"
        tableView.dataSource = self
        tableView.delegate = self
        
        settingsViewModel.roomChangeListener { room in
            self.roomIDLabel.text = room.roomID
            self.tableView.reloadData()
        }

        
        settingsViewModel.memberListChangeListener { memberList in
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
        let cells = [
            checkmarkCell(for: indexPath),
            memberCell(for: indexPath)
        ]
        return cells[indexPath.section]
    }
    
    func checkmarkCell(for indexPath: IndexPath) -> CheckmarkSettingTableViewCell {
        guard indexPath.section == 0 else {
            return CheckmarkSettingTableViewCell()
        }
        
        let checkmarkCell = tableView.dequeueReusableCell(withIdentifier: "CheckmarkSettingTableViewCell", for: indexPath) as! CheckmarkSettingTableViewCell
        checkmarkCell.queueType = settingsViewModel.queueTypes[indexPath.row]
        checkmarkCell.isChecked = settingsViewModel.currentQueueType == checkmarkCell.queueType
        return checkmarkCell
    }
    
    func memberCell(for indexPath: IndexPath) -> MemberTableViewCell {
        guard indexPath.section == 1 else {
            return MemberTableViewCell()
        }
        let memberCell = tableView.dequeueReusableCell(withIdentifier: "MemberTableViewCell", for: indexPath) as! MemberTableViewCell
        memberCell.member = settingsViewModel.memberList[indexPath.row]
        if settingsViewModel.isHost(memberCell.member) {
            memberCell.hostIndicatorLabel.isHidden = false
            memberCell.isUserInteractionEnabled = false
            memberCell.accessoryType = .none
        }
        return memberCell
    }
}

extension SettingsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let sectionTitles = ["Queue Modes", "Members"]
        return sectionTitles[section]
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cellSelectHandlers = [
            didSelectCheckmarkCell,
            didSelectMemberCell
        ]
        cellSelectHandlers[indexPath.section](indexPath)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func didSelectCheckmarkCell(at indexPath: IndexPath) {
        let selectedCheckmarkCell = checkmarkCell(for: indexPath)
        var room = settingsViewModel.room
        room.queueType = selectedCheckmarkCell.queueType.rawValue
        settingsViewModel.updateRoom(room)
    }
    
    func didSelectMemberCell(at indexPath: IndexPath) {
        let selectedMemberCell = memberCell(for: indexPath)
        let alert = UIAlertController(title: selectedMemberCell.member.displayName, message: nil, preferredStyle: .actionSheet)
        let removeMemberAction = UIAlertAction(title: "Remove", style: .destructive) { action in
            self.settingsViewModel.removeMember(selectedMemberCell.member)
        }
        alert.addAction(removeMemberAction)
        present(alert, animated: true) {
            alert.view.superview?.subviews[0].addGestureRecognizer(self.tapGestureRecognizer)
        }
    }
}

//// MARK: - UITableViewDataSource
//extension SettingsViewController: UITableViewDataSource {
//
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return 3
//    }
//
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        let sectionCounts = [1, 1, settingsViewModel.memberList.count]
//        return sectionCounts[section]
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        switch indexPath.section {
//        case 0:
//            let cell = tableView.dequeueReusableCell(withIdentifier: "SettingTableViewCell", for: indexPath) as! SettingTableViewCell
//            cell.label.text = "Appearance"
//            cell.valueLabel.text = "Automatic"
//            return cell
//        case 1:
//            let cell = tableView.dequeueReusableCell(withIdentifier: "SettingTableViewCell", for: indexPath) as! SettingTableViewCell
//            cell.label.text = "Queue Mode"
//            cell.valueLabel.text = "Fair"
//            if settingsViewModel.room.host.userID != settingsViewModel.authService.currentUser.userID {
//                cell.accessoryType = .none
//                cell.selectionStyle = .none
//            }
//            return cell
//        case 2:
//            let cell = tableView.dequeueReusableCell(withIdentifier: "SettingTableViewCell", for: indexPath) as! SettingTableViewCell
//            let hostId = settingsViewModel.room.host.userID
//            let member = settingsViewModel.memberList[indexPath.row]
//            cell.label.text = member.displayName
//            cell.valueLabel.text = hostId == member.userID ? "Host" : ""
//            if hostId == member.userID {
//                cell.accessoryType = .none
//                cell.selectionStyle = .none
//            }
//            return cell
//        default:
//            return UITableViewCell()
//        }
//    }
//}


//// MARK: - UITableViewDelegate
//extension SettingsViewController: UITableViewDelegate {
//
//    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        let sectionTitles = ["User Setting", "Room Info", "Members"]
//        return sectionTitles[section]
//    }
//
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let sectionTitle = ["User Setting", "Room Info", "Members"][indexPath.section]
//
//        switch sectionTitle {
//
//        case "User Setting":
//            showAlert(title: sectionTitle, message: nil, actions: createAlertActions(titles: ["Automatic", "Light","Dark"]) { alertAction  in
//                let cell = tableView.cellForRow(at: indexPath) as! SettingTableViewCell
//                cell.valueLabel.text = alertAction.title
//
//                guard
//                    let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
//                    let sceneDelegate = windowScene.delegate as? SceneDelegate,
//                    let window = sceneDelegate.window
//                else {
//                    return
//                }
//
//                var style: UIUserInterfaceStyle
//                switch alertAction.title {
//                case "Light":
//                    style = .light
//                case "Dark":
//                    style = .dark
//                default:
//                    style = .unspecified
//                }
//
//                UserDefaultsRepository().appearance = style.rawValue
//                window.overrideUserInterfaceStyle = style
//            })
//
//        case "Room Info":
//            if settingsViewModel.room.host.userID != settingsViewModel.authService.currentUser.userID {
//                return
//            }
//            showAlert(title: sectionTitle, message: nil, actions: createAlertActions(titles: ["Fair"]) { alertAction  in
//                let cell = tableView.cellForRow(at: indexPath) as! SettingTableViewCell
//                cell.label.text = alertAction.title
//            })
//
//        case "Members":
//            let hostId = settingsViewModel.room.host.userID
//            let member = settingsViewModel.memberList[indexPath.row]
//            if hostId == member.userID {
//                return
//            }
//            let alertActions = [
//                UIAlertAction(title: "Make Admin", style: .default, handler: nil),
//                UIAlertAction(title: "Remove", style: .destructive, handler: nil)
//            ]
//            showAlert(title: sectionTitle, message: nil, actions: alertActions)
//
//        default:
//            break
//        }
//
//        tableView.deselectRow(at: indexPath, animated: true)
//    }
//}
