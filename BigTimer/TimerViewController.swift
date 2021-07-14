//
//  ViewController.swift
//  BigTimer
//
//  Created by 임성민 on 2021/07/12.
//

import UIKit

class TimerViewController: UIViewController {
    @IBOutlet weak var hourLabel: UILabel!
    @IBOutlet weak var minuteLabel: UILabel!
    @IBOutlet weak var secondLabel: UILabel!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    
    private let timer = HMSTimer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(addTime), name: NSNotification.Name.addTime, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(changeTime), name: NSNotification.Name.changeTime, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(changeState), name: NSNotification.Name.changeState, object: nil)
    }

    @IBAction func touchUpPlusButton(_ sender: Any) {
        let timePicker = TimePickerViewController()
        let picker = UINavigationController(rootViewController: timePicker)
        present(picker, animated: true, completion: nil)
    }
    
    @objc private func addTime(_ notification: Notification) {
        guard let userInfo = notification.userInfo as? [String: UInt] else {
            return
        }
        if let hour = userInfo["hour"],
           let minute = userInfo["minute"],
           let second = userInfo["second"] {
            timer.addTime(hour: hour, minute: minute, second: second)
        }
        playButton.isEnabled = true
    }
    
    @objc private func changeTime(_ notification: Notification) {
        guard let userInfo = notification.userInfo as? [String: UInt] else {
            return
        }
        if let hour = userInfo["hour"] {
            self.hourLabel.text = hour.timeString
        }
        if let minute = userInfo["minute"] {
            self.minuteLabel.text = minute.timeString
        }
        if let second = userInfo["second"] {
            self.secondLabel.text = second.timeString
        }
    }
    
    @objc private func changeState(_ notification: Notification) {
        guard let userInfo = notification.userInfo as? [String: HMSTimer.TimerState],
              let timerState = userInfo["state"] else {
            return
        }
        
        /// 시간 추가 전 - 더하기 버튼 활성화, 재생 버튼 비활성화, 중지 버튼 비활성화
        /// 시간 추가 후 - 더하기 버튼 비활성화, 재생 버튼 활성화, 중지 버튼 활성화
        /// 재생 - 더하기 버튼 비활성화, 재생 버튼 정지 버튼으로 변경, 중지 버튼 활성화
        /// 정지 - 더하기 버튼 비활성화, 정지 버튼 재생 버튼으로 변경, 중지 버튼 활성화
        switch timerState {
        case .BeforeAddingTime:
            addButton.isEnabled = true
            playButton.isEnabled = false
            stopButton.isEnabled = false
            playButton.setImage(UIImage(systemName: "play"), for: .normal)
        case .AfterAddingTime:
            addButton.isEnabled = false
            playButton.isEnabled = true
            stopButton.isEnabled = true
        case .play:
            playButton.setImage(UIImage(systemName: "pause"), for: .normal)
        case .pause:
            playButton.setImage(UIImage(systemName: "play"), for: .normal)
        }
    }
    
    @IBAction func touchUpPlayButton(_ sender: Any) {
        switch timer.state {
        case .play:
            timer.pause()
        case .pause, .AfterAddingTime:
            timer.play()
        default:
            break
        }
    }
    
    @IBAction func touchUpStopButton(_ sender: Any) {
        timer.stop()
    }
}

