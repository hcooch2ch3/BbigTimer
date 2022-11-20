//
//  SettingsTableViewCell.swift
//  BigTimer
//
//  Created by 임성민 on 2021/07/19.
//

import UIKit

protocol SettingsTableViewCellDelegate: AnyObject {
    func switchValueDidChange(cell: SettingsTableViewCell, value: Bool)
}

class SettingsTableViewCell: UITableViewCell {
    
    static let reuseIdentifier = "SettingsTableViewCell"
    let label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    let `switch`: UISwitch = {
        let `switch` = UISwitch()
        `switch`.translatesAutoresizingMaskIntoConstraints = false
        return `switch`
    }()
    weak var delegate: SettingsTableViewCellDelegate?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(label)
        contentView.addSubview(`switch`)
        `switch`.addTarget(self, action: #selector(switchValueDidChange), for: .valueChanged)
        setupLayout()
    }
    
    @objc func switchValueDidChange() {
        delegate?.switchValueDidChange(cell: self, value: `switch`.isOn)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout() {
        NSLayoutConstraint.activate([
            label.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 15),
            label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            `switch`.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -15),
            `switch`.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        label.text = nil
        `switch`.isOn = false
    }

}
