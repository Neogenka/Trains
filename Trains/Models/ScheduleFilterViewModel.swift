//
//  ScheduleFilterViewModel.swift
//  Trains
//
//  Created by МAK on 10.03.2026.
//

import Foundation
import Observation

@MainActor
@Observable
final class ScheduleFilterViewModel {
    var selectedParts: Set<DayPart> = []
    var transfers: TransfersOption? = nil
}
