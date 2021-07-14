//
//  Clock.swift
//  BigTimer
//
//  Created by 임성민 on 2021/07/14.
//

import Foundation

class Clock {
    private lazy var timer: Timer? = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateClock), userInfo: nil, repeats: true)
    
    init() {
        timer?.fire()
    }
    
    @objc private func updateClock() {
        let date = DateFormatter.localizedString(from: Date(), dateStyle: .medium, timeStyle: .medium)
        NotificationCenter.default.post(name: NSNotification.Name.updateClock, object: nil, userInfo: ["clock": date])
    }
}
