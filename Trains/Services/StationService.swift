//
//  StationService.swift
//  Trains
//
//  Created by МAK on 10.03.2026.
//

import OpenAPIRuntime
import Foundation

typealias Station = Components.Schemas.Station

protocol StationServiceProtocol: Sendable {
    func getStations(for city: String) async throws -> [Station]
}

final actor StationService: StationServiceProtocol {
    
    private let stationsListService: StationsListServiceProtocol
    
    init(stationsListService: StationsListServiceProtocol) {
        self.stationsListService = stationsListService
    }
    
    func getStations(for city: String) async throws -> [Station] {
        let allStationsResponse = try await stationsListService.getAllStations()
        
        var resultStations: [Station] = []
        
        for country in allStationsResponse.countries ?? [] {
            for region in country.regions ?? [] {
                for settlement in region.settlements ?? [] {
                    if let settlementTitle = settlement.title,
                       settlementTitle.localizedCaseInsensitiveContains(city) {
                        
                        let trainStations = (settlement.stations ?? []).filter { station in
                            isRailwayStation(station)
                        }
                        resultStations.append(contentsOf: trainStations)
                    }
                }
            }
        }
        
        return resultStations
    }
    
    private func isRailwayStation(_ station: Station) -> Bool {
        if let stationType = station.station_type?.lowercased() {
            if stationType == "station"
                || stationType == "platform"
                || stationType == "stop"
                || stationType == "train_station" {
                return true
            }
        }
        if let esr = station.codes?.esr_code, !esr.isEmpty {
            return true
        }
        return false
    }
    
    private func deduplicateAndSort(_ items: [Station]) -> [Station] {
        var seen = Set<String>()
        return items.filter { st in
            let key =
            st.codes?.yandex_code ??
            st.codes?.esr_code ??
            st.code ?? st.title ?? UUID().uuidString
            return seen.insert(key).inserted
        }
        .sorted { ($0.title ?? "") < ($1.title ?? "") }
    }
}
