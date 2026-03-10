//
//  MockStationService.swift
//  Trains
//
//  Created by МAK on 10.03.2026.
//

import OpenAPIRuntime
import Foundation

@MainActor
class MockStationService: StationServiceProtocol {
    func getStations(for city: String) async throws -> [Station] {
        try await Task.sleep(nanoseconds: 1_000_000_000)
        
        switch city.lowercased() {
            case "москва":
                return [
                    Station(title: "Киевский вокзал", codes: nil),
                    Station(title: "Курский вокзал", codes: nil),
                    Station(title: "Ярославский вокзал", codes: nil),
                    Station(title: "Белорусский вокзал", codes: nil),
                    Station(title: "Савеловский вокзал", codes: nil),
                    Station(title: "Ленинградский вокзал", codes: nil)
                ]
            case "санкт-петербург", "питер", "спб":
                return [
                    Station(title: "Московский вокзал", codes: nil),
                    Station(title: "Финляндский вокзал", codes: nil),
                    Station(title: "Ладожский вокзал", codes: nil),
                    Station(title: "Балтийский вокзал", codes: nil)
                ]
            case "сочи":
                return [
                    Station(title: "Сочи Центральный", codes: nil),
                    Station(title: "Адлер", codes: nil)
                ]
            default:
                return [
                    Station(title: "Центральный вокзал", codes: nil),
                    Station(title: "Северный вокзал", codes: nil),
                    Station(title: "Южный вокзал", codes: nil)
                ]
        }
    }
}
