//
//  Int+convertToTimeString.swift
//  BigTimer
//
//  Created by 임성민 on 2021/07/12.
//

import Foundation

extension UInt {
    var timeString: String {
        return self / 10 == 0 ? "0\(self)" : String(self)
    }
}
