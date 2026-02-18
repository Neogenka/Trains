//
//  StationsListService.swift
//  Trains
//
//  Created by МAK on 17.01.2026.
//

import OpenAPIRuntime
import Foundation

typealias AllStationsResponse = Components.Schemas.AllStationsResponse

protocol StationsListServiceProtocol {
    func getAllStations() async throws -> AllStationsResponse
}

final class StationsListService: StationsListServiceProtocol {
    
    private let client: Client
    private let apikey: String
    
    init(client: Client, apikey: String) {
        self.client = client
        self.apikey = apikey
    }
    
    func getAllStations() async throws -> AllStationsResponse {
        let response = try await client.getAllStations(query: .init(apikey: apikey))
        
        let responseBody = try response.ok.body.html
        
        let limit = 50 * 1024 * 1024

        let fullData = try await Data(collecting: responseBody, upTo: limit)
        
        let allStations = try JSONDecoder().decode(AllStationsResponse.self, from: fullData)
        
        return allStations
    }
}
