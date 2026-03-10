//
//  SearchService.swift
//  Trains
//
//  Created by МAK on 17.01.2026.
//

import OpenAPIRuntime
import Foundation

typealias SearchResponse = Components.Schemas.Segments

protocol SearchServiceProtocol: Actor, Sendable {
    func getScheduleBetweenStations(from: String, to: String) async throws -> SearchResponse
}

final actor SearchService: SearchServiceProtocol {
    private let client: Client
    private let apikey: String
    
    init(client: Client, apikey: String){
        self.client = client
        self.apikey = apikey
    }
    
    func getScheduleBetweenStations(from: String, to: String) async throws -> SearchResponse {
        let response = try await client.getScheduleBetweenStations(
            query: .init(
                apikey: apikey,
                from: from,
                to: to,
                date: Date().toISODateString(),
                transfers: true
            )
        )
        return try response.ok.body.json
    }
}
