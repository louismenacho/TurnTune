//
//  SettingsTableViewController.swift
//  TurnTune
//
//  Created by Louis Menacho on 4/21/21.
//

import UIKit

class SettingsTableViewController: UITableViewController {
    
    var roomViewModel: RoomViewModel?

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Settings"
    }
    
    func showAlert(title: String, message: String?, actions: [UIAlertAction]) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        actions.forEach { alert.addAction($0) }
        present(alert, animated: true) {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissAction))
            alert.view.superview?.subviews[0].addGestureRecognizer(tapGesture)
        }
    }
    
    func createAlertActions(titles: [String], handler: ((UIAlertAction) -> Void)? = nil) -> [UIAlertAction] {
        return titles.map { UIAlertAction(title: $0, style: .default, handler: handler) }
    }
    
    @objc func dismissAction() {
        self.dismiss(animated: true, completion: nil)
    }
}



// MARK: - UITableViewDataSource
extension SettingsTableViewController {

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionCounts = [1, 1, roomViewModel?.memberList.count ?? 0]
        return sectionCounts[section]
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SettingTableViewCell", for: indexPath) as! SettingTableViewCell
            cell.label.text = "Appearance"
            cell.valueLabel.text = "Automatic"
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SettingTableViewCell", for: indexPath) as! SettingTableViewCell
            cell.label.text = "Queue Mode"
            cell.valueLabel.text = "Fair"
            if roomViewModel?.room.hostId != roomViewModel?.authentication.currentUser()?.uid {
                cell.accessoryType = .none
                cell.selectionStyle = .none
            }
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SettingTableViewCell", for: indexPath) as! SettingTableViewCell
            let hostId = roomViewModel?.room.hostId
            let member = roomViewModel?.memberList[indexPath.row]
            cell.label.text = member?.displayName
            cell.valueLabel.text = hostId == member?.id ? "Host" : ""
            if hostId == member?.id {
                cell.accessoryType = .none
                cell.selectionStyle = .none
            }
            return cell
        default:
            return UITableViewCell()
        }
    }
}



// MARK: - UITableViewDelegate
extension SettingsTableViewController {
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let sectionTitles = ["User Setting", "Room Info", "Members"]
        return sectionTitles[section]
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let sectionTitle = ["User Setting", "Room Info", "Members"][indexPath.section]
        
        
        
        switch sectionTitle {
                
        case "User Setting":
            showAlert(title: sectionTitle, message: nil, actions: createAlertActions(titles: ["Automatic", "Light","Dark"]) { alertAction  in
                let cell = tableView.cellForRow(at: indexPath) as! SettingTableViewCell
                cell.valueLabel.text = alertAction.title
            
                guard
                    let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                    let sceneDelegate = windowScene.delegate as? SceneDelegate,
                    let window = sceneDelegate.window
                else {
                    return
                }
                
                var style: UIUserInterfaceStyle
                switch alertAction.title {
                case "Light":
                    style = .light
                case "Dark":
                    style = .dark
                default:
                    style = .unspecified
                }
                
                UserDefaultsRepository().appearance = style.rawValue
                window.overrideUserInterfaceStyle = style
            })
            
        case "Room Info":
            if roomViewModel?.room.hostId != roomViewModel?.authentication.currentUser()?.uid {
                return
            }
            showAlert(title: sectionTitle, message: nil, actions: createAlertActions(titles: ["Fair"]) { alertAction  in
                let cell = tableView.cellForRow(at: indexPath) as! SettingTableViewCell
                cell.label.text = alertAction.title
            })
            
        case "Members":
            let hostId = roomViewModel?.room.hostId
            let member = roomViewModel?.memberList[indexPath.row]
            if hostId == member?.id {
                return
            }
            let alertActions = [
                UIAlertAction(title: "Make Admin", style: .default, handler: nil),
                UIAlertAction(title: "Remove", style: .destructive, handler: nil)
            ]
            showAlert(title: sectionTitle, message: nil, actions: alertActions)
            
        default:
            break
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
