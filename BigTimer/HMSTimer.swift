//
//  Timer.swift
//  BigTimer
//
//  Created by 임성민 on 2021/07/14.
//

import Foundation
import UserNotifications

final class HMSTimer {
    private var hour: UInt = 0 {
        didSet {
            NotificationCenter.default.post(name: NSNotification.Name.changeTime, object: nil, userInfo: ["hour": self.hour])
        }
    }
    private var minute: UInt = 0 {
        didSet {
            NotificationCenter.default.post(name: NSNotification.Name.changeTime, object: nil, userInfo: ["minute": self.minute])
        }
    }
    private var second: UInt = 0 {
        didSet {
            NotificationCenter.default.post(name: NSNotification.Name.changeTime, object: nil, userInfo: ["second": self.second])
        }
    }
    private(set) var state: TimerState = .BeforeAddingTime {
        didSet {
            NotificationCenter.default.post(name: NSNotification.Name.changeState, object: nil, userInfo: ["state": self.state])
        }
    }
    private var timer: Timer?
    
    deinit {
        timer?.invalidate()
    }
    
    @objc private func decreaseTime() {
        if second > 0 {
            second -= 1
        } else {
            if minute > 0 {
                minute -= 1
                second = 59
            } else {
                if hour > 0 {
                    hour -= 1
                    minute = 59
                    second = 59
                }
            }
        }
        if hour == 0 && minute == 0 && second == 0 {
            timeOver()
        }
    }
    
    func addTime(hour: UInt, minute: UInt, second: UInt) {
        self.hour = hour
        self.minute = minute
        self.second = second
        state = .AfterAddingTime
    }
    
    func play() {
        setUserNotification()
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(decreaseTime), userInfo: nil, repeats: true)
        state = .play
    }
    
    func pause() {
        removeUserNotification()
        if let timer = self.timer {
            timer.invalidate()
        }
        state = .pause
    }
    
    func stop() {
        removeUserNotification()
        if let timer = self.timer {
            timer.invalidate()
        }
        hour = 0
        minute = 0
        second = 0
        state = .BeforeAddingTime
    }
    
    private func timeOver() {
        NotificationCenter.default.post(name: NSNotification.Name.timeOver, object: nil, userInfo: nil)
        if let timer = self.timer {
            timer.invalidate()
        }
        state = .BeforeAddingTime
    }
    
    private lazy var notificationID = "BbigTimer"
    
    private func setUserNotification() {
        let content = UNMutableNotificationContent()
        content.title = "BbigTimer"
        content.body = "Time Over"
        content.sound = UNNotificationSound(named: UNNotificationSoundName("zapsplat_alarm_sound.aiff"))
        let timeInterval = Double(second) + Double(minute * 60) + Double(hour * 3600)
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
        let request = UNNotificationRequest(identifier: notificationID, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
    
    private func removeUserNotification() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [notificationID])
    }
}

extension HMSTimer {
    enum TimerState {
        case BeforeAddingTime
        case AfterAddingTime
        case play
        case pause
    }
}
