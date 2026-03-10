//
//  CityService.swift
//  Trains
//
//  Created by МAK on 10.03.2026.
//

import OpenAPIRuntime
import Foundation

typealias City = Components.Schemas.Settlement

protocol CityServiceProtocol: Sendable{
    func getAllCities() async throws -> [City]
}

final actor CityService: CityServiceProtocol {
    
    private let client: Client
    private let apikey: String
    private var cachedCities: [City]?
    
    init(client: Client, apikey: String) {
        self.client = client
        self.apikey = apikey
    }
    
    func getAllCities() async throws -> [City] {
        if let cachedCities = cachedCities {
            return cachedCities
        }
        
        let response = try await client.getAllStations(query: .init(apikey: apikey))
        let responseBody = try response.ok.body.html
        let limit = 50 * 1024 * 1024
        
        let fullData = try await Data(collecting: responseBody, upTo: limit)
        let allStations = try JSONDecoder().decode(AllStationsResponse.self, from: fullData)
        var cities: [City] = []

        guard let countries = allStations.countries else {
            return []
        }
        
        for country in countries {
            guard let regions = country.regions else { continue }
            
            for region in regions {
                guard let settlements = region.settlements else { continue }
                cities.append(contentsOf: settlements)
            }
        }
        
        cachedCities = cities
        return cities
    }
}
