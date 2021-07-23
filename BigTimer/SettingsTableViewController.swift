//
//  SettingViewController.swift
//  BigTimer
//
//  Created by 임성민 on 2021/07/18.
//

import UIKit

class SettingsTableViewController: UITableViewController {
    
    weak var timerViewController: TimerViewController? = nil
        
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(SettingsTableViewCell.self, forCellReuseIdentifier: SettingsTableViewCell.reuseIdentifier)
        tableView.allowsSelection = false
        setupNavigationBar()
    }
    
    private func setupNavigationBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(touchUpDoneButton))
    }
    
    @objc private func touchUpDoneButton() {
        dismiss(animated: true, completion: nil)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SettingsTableViewCell.reuseIdentifier, for: indexPath) as? SettingsTableViewCell else {
            return UITableViewCell()
        }
        cell.delegate = self
        switch indexPath.row {
        case Settings.AwakeMode.rawValue:
            cell.label.text = "Awake Mode"
            if let timerViewController = timerViewController {
                cell.switch.isOn = timerViewController.isAwakeMode
            }
        case Settings.CurrentTime.rawValue:
            cell.label.text = "Current Time"
            cell.switch.isOn = Clock.shared.state
        default:
            break
        }
        return cell
    }

}

extension SettingsTableViewController: SettingsTableViewCellDelegate {
    func switchValueDidChange(cell: SettingsTableViewCell, value: Bool) {
        guard let indexPath = tableView.indexPath(for: cell) else {
            return
        }
        switch indexPath.row {
        case Settings.AwakeMode.rawValue:
            if let timerViewController = timerViewController {
                timerViewController.isAwakeMode = value
            }
        case Settings.CurrentTime.rawValue:
            Clock.shared.state = value
        default:
            break
        }
    }
}

enum Settings: Int {
    case AwakeMode = 0, CurrentTime
}
