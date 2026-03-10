//
//  APIFactory.swift
//  Trains
//
//  Created by МAK on 10.03.2026.
//

import OpenAPIRuntime
import OpenAPIURLSession
import Foundation

enum APIFactory {
    
    static func makeSearchService() throws -> SearchServiceProtocol {
        try SearchService(client: TestAPI.client, apikey: TestAPI.apiKey)
    }
    
    static func makeCarrierService() throws -> CarrierServiceProtocol {
        try CarrierService(client: TestAPI.client, apikey: TestAPI.apiKey)
    }
    
    @MainActor
    static func makeCityService() throws -> CityServiceProtocol {
        try CityService(client: TestAPI.client, apikey: TestAPI.apiKey)
    }
    
    @MainActor
    static func makeStationService() throws -> StationServiceProtocol {
        let stationsListService = StationsListService(
            client: try TestAPI.client,
            apikey: TestAPI.apiKey
        )
        return StationService(stationsListService: stationsListService)
    }
}
