//
//  MoneyStringExtension.swift
//  RxSwiftTryout
//
//  Created by Benjamin Stone on 6/14/18.
//  Copyright © 2018 ShopKeep. All rights reserved.
//

import Foundation

extension Double {
    func stringFormatted() -> String {
        return String(format: "Tip Amount: $%.02f", self)
    }
    func percentageFormatted(of priceBeforeTip: Double) -> String {
        let tipPercent = self / priceBeforeTip * 100
        return String(format: "%.02f", tipPercent) + " %"
    }
}
