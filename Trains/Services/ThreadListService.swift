//
//  ThreadStationsService.swift
//  Trains
//
//  Created by МAK on 17.01.2026.
//

import OpenAPIRuntime

typealias ThreadStationsResponse = Components.Schemas.ThreadStationsResponse

protocol ThreadServiceProtocol: Actor{
    func getRouteStations(uid: String) async throws -> ThreadStationsResponse
}

final actor ThreadService: ThreadServiceProtocol {
    
    private let client: Client
    private let apikey: String
    
    init(client: Client, apikey: String) {
        self.client = client
        self.apikey = apikey
    }
    
    func getRouteStations(uid: String) async throws -> ThreadStationsResponse {
        let response = try await client.getRouteStations(query: .init(apikey: apikey, uid: uid))
        return try response.ok.body.json
    }
}
