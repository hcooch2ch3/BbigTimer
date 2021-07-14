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
    
    private lazy var timerOperation: TimerOperation? = nil
    private let operationQueue = OperationQueue()
    
    func addTime(hour: UInt, minute: UInt, second: UInt) {
        self.hour = hour
        self.minute = minute
        self.second = second
        state = .AfterAddingTime
    }
    
    func play() {
        let timerOperation = TimerOperation(timer: self)
        operationQueue.addOperation(timerOperation)
        self.timerOperation = timerOperation
        state = .play
    }
    
    func pause() {
        guard let timerOperation = timerOperation else {
            return
        }
        timerOperation.cancel()
        state = .pause
    }
    
    func stop() {
        guard let timerOperation = timerOperation else {
            return
        }
        timerOperation.cancel()
        hour = 0
        minute = 0
        second = 0
        state = .BeforeAddingTime
    }
}

extension HMSTimer {
    private class TimerOperation: Operation {
        private unowned var timer: HMSTimer
        
        init(timer: HMSTimer) {
            self.timer = timer
            super.init()
        }
        
        override func main() {
            while timer.hour >= 0 {
                while timer.minute >= 0 {
                    while timer.second > 0 {
                        sleep(1)
                        if self.isCancelled || self.isFinished {
                            return
                        }
                        timer.second -= 1
                    }
                    if timer.minute == 0 {
                        break
                    }
                    sleep(1)
                    timer.minute -= 1
                    timer.second = 59
                }
                sleep(1)
                timer.hour -= 1
                timer.minute = 59
                timer.second = 59
            }
        }
    }

    enum TimerState {
        case BeforeAddingTime
        case AfterAddingTime
        case play
        case pause
    }
}
