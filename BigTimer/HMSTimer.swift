//
//  Timer.swift
//  BigTimer
//
//  Created by 임성민 on 2021/07/14.
//

import Foundation

class HMSTimer {
    private var hour: UInt = 0 {
        didSet {
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: NSNotification.Name.changeTime, object: nil, userInfo: ["hour": self.hour])
            }
        }
    }
    private var minute: UInt = 0 {
        didSet {
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: NSNotification.Name.changeTime, object: nil, userInfo: ["minute": self.minute])
            }
        }
    }
    private var second: UInt = 0 {
        didSet {
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: NSNotification.Name.changeTime, object: nil, userInfo: ["second": self.second])
            }
        }
    }
    private(set) var state: TimerState = .BeforeAddingTime {
        didSet {
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: NSNotification.Name.changeState, object: nil, userInfo: ["state": self.state])
            }
        }
    }
    
    private var timer: Timer?
    
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
    }
    
    func addTime(hour: UInt, minute: UInt, second: UInt) {
        self.hour = hour
        self.minute = minute
        self.second = second
        state = .AfterAddingTime
    }
    
    func play() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(decreaseTime), userInfo: nil, repeats: true)
        state = .play
    }
    
    func pause() {
        guard let timer = self.timer else {
            return
        }
        timer.invalidate()
        state = .pause
    }
    
    func stop() {
        guard let timer = self.timer else {
            return
        }
        timer.invalidate()
        hour = 0
        minute = 0
        second = 0
        state = .BeforeAddingTime
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
