//
//  Notification.Name+CustomNotification.swift
//  BigTimer
//
//  Created by 임성민 on 2021/07/12.
//

import Foundation

extension NSNotification.Name {
    static let addTime = NSNotification.Name(rawValue: "addTime")
    static let changeTime = NSNotification.Name(rawValue: "changeTime")
    static let changeState = NSNotification.Name(rawValue: "changeState")
    static let timeOver = NSNotification.Name(rawValue: "timeOver")
    static let updateClock = NSNotification.Name(rawValue: "updateClock")
    static let changeClockState = NSNotification.Name(rawValue: "changeClockState")
}
