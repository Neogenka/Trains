//
//  CarrierService.swift
//  Trains
//
//  Created by МAK on 17.01.2026.
//

import OpenAPIRuntime
import Foundation

typealias CarrierResponse = Components.Schemas.CarrierResponse

protocol CarrierServiceProtocol: Actor, Sendable {
    func getCarrierInfo(code: String) async throws -> CarrierResponse
}

final actor CarrierService: CarrierServiceProtocol {
    
    private let client: Client
    private let apikey: String
    
    init(client: Client, apikey: String) {
        self.client = client
        self.apikey = apikey
    }
    
    func getCarrierInfo(code: String) async throws -> CarrierResponse {
        let response = try await client.getCarrierInfo(query: .init(apikey: apikey, code: code))
        return try response.ok.body.json
    }
    
    func debugCarrierStructure(_ response: CarrierResponse) {
        dump(response)
    }
}
