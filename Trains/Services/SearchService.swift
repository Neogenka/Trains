//
//  SearchService.swift
//  Trains
//
//  Created by МAK on 17.01.2026.
//

import OpenAPIRuntime

typealias SearchResponse = Components.Schemas.Segments

protocol SearchServiceProtocol {
    func getScheduleBetweenStations(from: String, to: String) async throws -> SearchResponse
}

final class SearchService: SearchServiceProtocol {
    private let client: Client
    private let apikey: String
    
    init(client: Client, apikey: String){
        self.client = client
        self.apikey = apikey
    }
    
    func getScheduleBetweenStations(from: String, to: String) async throws -> SearchResponse {
        let response = try await client.getScheduleBetweenStations(query: .init(apikey: apikey, from: from, to: to))
        return try response.ok.body.json
    }
}
