//
//  MockCityService.swift
//  Trains
//
//  Created by МAK on 10.03.2026.
//

import OpenAPIRuntime
import Foundation

@MainActor
class MockCityService: CityServiceProtocol {
    func getAllCities() async throws -> [City] {
        return [
            City(title: "Москва", codes: nil),
            City(title: "Санкт-Петербург", codes: nil),
            City(title: "Сочи", codes: nil),
            City(title: "Казань", codes: nil),
            City(title: "Новосибирск", codes: nil)
        ]
    }
}
