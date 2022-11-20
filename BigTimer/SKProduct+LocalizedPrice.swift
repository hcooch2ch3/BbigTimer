//
//  SKProduct+LocalizedPrice.swift
//  BigTimer
//
//  Created by 임성민 on 2022/11/21.
//

import Foundation
import StoreKit

extension SKProduct {
    private static let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        return formatter
    }()

    var isFree: Bool {
        price == 0.00
    }

    var localizedPrice: String? {
        guard !isFree else {
            return nil
        }
        
        let formatter = SKProduct.formatter
        formatter.locale = priceLocale
        
        return formatter.string(from: price)
    }
}
