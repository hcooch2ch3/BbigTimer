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
        timePicker.dataSource = self
        timePicker.delegate = self
        view.backgroundColor = .systemGray2
        setupLayout()
        setupNavigationBar()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        addTime()
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
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(touchUpResetButton))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(touchUpDoneButton))
    }
    
    @objc private func touchUpResetButton() {
        timePicker.selectRow(0, inComponent: 0, animated: true)
        timePicker.selectRow(0, inComponent: 1, animated: true)
        timePicker.selectRow(0, inComponent: 2, animated: true)
        hour = 0
        minute = 0
        second = 0
    }
    
    @objc private func touchUpDoneButton() {
        dismiss(animated: true, completion: nil)
    }
    
    private func addTime() {
        if hour == 0 && minute == 0 && second == 0 {
            return
        }
        let userInfo = ["hour": hour, "minute": minute, "second": second]
        NotificationCenter.default.post(name: NSNotification.Name.addTime, object: nil, userInfo: userInfo)
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
