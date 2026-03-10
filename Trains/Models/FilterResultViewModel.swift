//
//  FilterResultViewModel.swift
//  Trains
//
//  Created by МAK on 10.03.2026.
//

import Foundation
import Observation

@MainActor
@Observable
final class FilterResultViewModel {
    let headerFrom: String
    let headerTo: String
    let items: [CarrierRowViewModel]
    
    init(headerFrom: String, headerTo: String, items: [CarrierRowViewModel]) {
        self.headerFrom = headerFrom
        self.headerTo = headerTo
        self.items = items
    }
}
