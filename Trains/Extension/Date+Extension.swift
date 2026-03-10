//
//  Date+Extension.swift
//  Trains
//
//  Created by МAK on 10.03.2026.
//

import Foundation

extension Date {
    func toISODateString() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: self)
    }
}
