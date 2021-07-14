//
//  TimePickerViewController.swift
//  BigTimer
//
//  Created by 임성민 on 2021/07/12.
//

import UIKit

class TimePickerViewController: UIViewController {
    private var hour: UInt = 0
    private var minute: UInt = 0
    private var second: UInt = 0
    
    private let timePicker: UIPickerView = {
        let timePicker = UIPickerView()
        timePicker.translatesAutoresizingMaskIntoConstraints = false
        return timePicker
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .darkGray
        timePicker.dataSource = self
        timePicker.delegate = self
        setupLayout()
        setupNavigationBar()
    }
    
    private func setupLayout() {
        view.addSubview(timePicker)
        NSLayoutConstraint.activate([
            timePicker.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 10),
            timePicker.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -10),
            timePicker.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func setupNavigationBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(touchUpCloseButton))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(touchUpAddButton))
    }
    
    @objc private func touchUpCloseButton() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func touchUpAddButton() {
        if hour == 0 && minute == 0 && second == 0 {
            return
        }
        let userInfo = ["hour": hour, "minute": minute, "second": second]
        NotificationCenter.default.post(name: NSNotification.Name.addTime, object: nil, userInfo: userInfo)
        dismiss(animated: true, completion: nil)
    }

}

extension TimePickerViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 3
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0:
            return 24
        default:
            return 60
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return UInt(row).timeString
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch component {
        case 0:
            hour = UInt(row)
        case 1:
            minute = UInt(row)
        case 2:
            second = UInt(row)
        default:
            break
        }
    }
}
