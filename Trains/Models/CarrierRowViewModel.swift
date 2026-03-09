//
//  CarrierRowViewModel.swift
//  Trains
//
//  Created by МAK on 18.02.2026.
//

import SwiftUI

// MARK: - ViewModel
struct CarrierRowViewModel: Identifiable {
    let id = UUID()
    let carrierName: String
    let logoSystemName: String?
    let dateText: String
    let departTime: String
    let arriveTime: String
    let durationText: String
    let note: String?
}

extension CarrierRowViewModel {
    static let mock: [CarrierRowViewModel] = [
        .init(carrierName: "РЖД", logoSystemName: "rzd",
              dateText: "14 января", departTime: "22:30", arriveTime: "08:15",
              durationText: "20 часов", note: "С пересадкой в Костроме"),
        .init(carrierName: "ФГК", logoSystemName: "fgk",
              dateText: "15 января", departTime: "01:15", arriveTime: "09:00",
              durationText: "9 часов", note: nil),
        .init(carrierName: "Урал логистика", logoSystemName: "ural",
              dateText: "15 января", departTime: "12:30", arriveTime: "21:00",
              durationText: "9 часов", note: nil),
        .init(carrierName: "РЖД", logoSystemName: "rzd",
              dateText: "17 января", departTime: "22:30", arriveTime: "08:15",
              durationText: "20 часов", note: "С пересадкой в Костроме"),
        .init(carrierName: "РЖД", logoSystemName: "rzd",
              dateText: "17 января", departTime: "22:30", arriveTime: "08:15",
              durationText: "20 часов", note: "С пересадкой в Костроме"),
        .init(carrierName: "Урал логистика", logoSystemName: "ural",
              dateText: "17 января", departTime: "12:30", arriveTime: "21:00",
              durationText: "9 часов", note: nil)
    ]
}
