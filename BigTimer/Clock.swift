//
//  Clock.swift
//  BigTimer
//
//  Created by 임성민 on 2021/07/14.
//

import Foundation

final class Clock {
    static let shared = Clock()
    private lazy var timer: Timer? = nil
    
    var state: Bool = {
        UserDefaults.standard.register(defaults: ["clockState": true])
        return UserDefaults.standard.bool(forKey: "clockState")
    }()
    {
        didSet {
            if state {
                timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(updateClock), userInfo: nil, repeats: true)
            } else {
                timer?.invalidate()
                NotificationCenter.default.post(name: NSNotification.Name.updateClock, object: nil, userInfo: nil)
            }
            UserDefaults.standard.setValue(state, forKey: "clockState")
        }
    }
    
    private init() {
        if state {
            timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(updateClock), userInfo: nil, repeats: true)
        }
    }
    
    deinit {
        timer?.invalidate()
    }
    
    @objc private func updateClock() {
        let currentDate = Date()
        let date = DateFormatter.localizedString(from: currentDate, dateStyle: .medium, timeStyle: .none)
        let hour = String(format: "%02d", Calendar.current.component(.hour, from: currentDate))
        let minute = String(format: "%02d", Calendar.current.component(.minute, from: currentDate))
        let second = String(format: "%02d", Calendar.current.component(.second, from: currentDate))
        
        let userInfo = ["date": date, "hour": hour, "minute": minute, "second": second]
        NotificationCenter.default.post(name: NSNotification.Name.updateClock, object: nil, userInfo: userInfo)
    }
}
